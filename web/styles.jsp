<%-- 
    Document   : styles
    Created on : Jan 18, 2026, 3:10:19 PM
    Author     : izzat
--%>

<%@page contentType="text/css" pageEncoding="UTF-8"%>
<style>
  :root {
    --rt-primary: #5c59f2;
    --rt-primary-hover: #4e4bc7;
    --rt-bg: #f9fafb;
    --rt-border: #e5e7eb;
    --rt-text-dark: #111827;
    --rt-text-muted: #6b7280;
  }

  body {
    font-family: 'Inter', sans-serif;
    background-color: var(--rt-bg);
    color: var(--rt-text-dark);
  }

  .hero {
    padding: 5rem 0;
  }

  .hero-card {
    background: white;
    border-radius: 1rem;
    padding: 2rem;
    box-shadow: 0 0.5rem 1.5rem rgba(0,0,0,0.1);
  }

  .section-title {
    font-weight: 700;
    color: #1f2937;
  }

  .card-custom {
    border-radius: 1rem;
    box-shadow: 0 0.5rem 1.5rem rgba(0,0,0,0.08);
    border: 0;
  }

  .btn-primary-custom {
    background-color: var(--rt-primary);
    border: none;
  }

  .btn-primary-custom:hover {
    background-color: var(--rt-primary-hover);
  }

  /* LOGIN OVERLAY */
  .login-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.6);
    display: none;
    justify-content: center;
    align-items: center;
    z-index: 9999;
    padding: 1rem;
  }

  .login-card {
    background: #fff;
    border-radius: 1rem;
    padding: 2rem;
    max-width: 420px;
    width: 100%;
    box-shadow: 0 0.5rem 1.5rem rgba(0,0,0,0.15);
  }

  .login-icon {
    background-color: #4f46e5;
    padding: 0.75rem;
    border-radius: 0.75rem;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 1rem;
  }

  .close-btn {
    position: absolute;
    top: 1rem;
    right: 1rem;
    background: transparent;
    border: none;
    font-size: 1.5rem;
    color: white;
  }
  .navbar {
  background: white;
  box-shadow: 0 0.5rem 1.5rem rgba(0,0,0,0.08);
  z-index: 1000;
}
:root {
            --rt-primary: #5c59f2;
            --rt-primary-hover: #4e4bc7;
            --rt-bg: #f9fafb;
            --rt-border: #e5e7eb;
            --rt-text-dark: #111827;
            --rt-text-muted: #6b7280;
        }

        body { 
            font-family: 'Inter', sans-serif; 
            background-color: var(--rt-bg); 
            color: var(--rt-text-dark);
        }

        /* Navbar & Profile */
        .navbar {
            background: white !important;
            border-bottom: 1px solid var(--rt-border);
            padding: 0.75rem 0;
        }
        .user-profile-tag {
            background: #eff6ff;
            color: var(--rt-primary);
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        /* Nav Pills (Sub-navigation) */
        .nav-pills-custom .nav-link {
            color: var(--rt-text-muted);
            font-weight: 500;
            padding: 10px 20px;
            border-radius: 8px;
        }
        .nav-pills-custom .nav-link.active {
            background-color: var(--rt-primary);
            color: white;
        }

        /* Modern Cards */
        .card {
            border: 1px solid var(--rt-border);
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            background: white;
            overflow: hidden;
        }
        .card-header {
            background: white;
            border-bottom: 1px solid var(--rt-border);
            padding: 1.25rem 1.5rem;
            font-weight: 600;
            font-size: 1.1rem;
        }

        /* Form Styling */
        .form-label { font-size: 0.875rem; font-weight: 500; color: var(--rt-text-muted); }
        .form-control { 
            border-radius: 8px; 
            padding: 0.6rem 1rem; 
            border: 1px solid var(--rt-border);
        }
        .form-control:focus {
            border-color: var(--rt-primary);
            box-shadow: 0 0 0 4px rgba(92, 89, 242, 0.1);
        }

        /* Table Design */
        .table thead th {
            background: #fcfcfd;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--rt-text-muted);
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--rt-border);
        }
        .table tbody td { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--rt-border); }

        /* Status Pills */
        .status-pill {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .status-running { background: #ecfdf5; color: #059669; }
        .status-stopped { background: #f3f4f6; color: #6b7280; }

        /* Buttons */
        .btn-rt-primary {
            background-color: var(--rt-primary);
            color: white;
            border: none;
            font-weight: 600;
            border-radius: 8px;
            transition: all 0.2s;
        }
        .btn-rt-primary:hover { background-color: var(--rt-primary-hover); color: white; }
</style>
