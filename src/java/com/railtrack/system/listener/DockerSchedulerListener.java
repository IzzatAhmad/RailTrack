package com.railtrack.system.listener;

import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.model.Project;
import com.railtrack.system.service.DockerService;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class DockerSchedulerListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;
    private ProjectDAO projectDAO;
    private DockerService dockerService;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        projectDAO = new ProjectDAO();
        dockerService = new DockerService();
        scheduler = Executors.newSingleThreadScheduledExecutor();

        System.out.println("Starting Docker Active Heartbeat Scheduler...");
        
        scheduler.scheduleAtFixedRate(() -> {
            try {
                List<Project> activeProjects = projectDAO.findRunningProjects();
                for (Project p : activeProjects) {
                    String liveState = dockerService.getContainerState(p.getId());
                    if ("running".equals(liveState)) {
                        // Increment runtime in DB by 300 seconds (5 mins)
                        projectDAO.incrementRunningTime(p.getId(), 300);
                        
                        // Enforce stop if limit exceeded
                        long todaySecs = projectDAO.getTodayRunningSeconds(p.getId());
                        if (todaySecs >= DockerService.DAILY_LIMIT_SECONDS) {
                            System.out.println("Project " + p.getId() + " exceeded daily limit. Auto-stopping.");
                            dockerService.stopProject(p, 0); // Auto-stop by system (performedById = 0)
                        }
                    } else {
                        // Reconcile status if container crashed out-of-band
                        projectDAO.updateDockerStatus(p.getId(), "stopped");
                    }
                }
            } catch (Exception e) { 
                e.printStackTrace(); 
            }
        }, 0, 5, TimeUnit.MINUTES);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            System.out.println("Shutting down Docker Active Heartbeat Scheduler...");
            scheduler.shutdownNow();
        }
    }
}
