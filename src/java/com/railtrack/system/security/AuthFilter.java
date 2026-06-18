package com.railtrack.system.security;

// Intentionally empty — duplicate of com.railtrack.system.controller.AuthFilter.
// Having two @WebFilter classes caused Tomcat to fail mapping /student/dashboard
// and all role-prefixed URLs. The active filter is in the controller package.