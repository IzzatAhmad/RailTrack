/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.exception;

/**
 *
 * @author izzat
 */
public class DockerException extends Exception {
 
    private final int    projectId;
    private final String dockerCommand;
 
    public DockerException(int projectId, String dockerCommand, String message) {
        super(message);
        this.projectId     = projectId;
        this.dockerCommand = dockerCommand;
    }
 
    public DockerException(int projectId, String dockerCommand, String message, Throwable cause) {
        super(message, cause);
        this.projectId     = projectId;
        this.dockerCommand = dockerCommand;
    }
 
    public int    getProjectId()     { return projectId; }
    public String getDockerCommand() { return dockerCommand; }
 
    @Override
    public String toString() {
        return "DockerException{projectId=" + projectId
                + ", cmd='" + dockerCommand + "', msg='" + getMessage() + "'}";
    }
}
 