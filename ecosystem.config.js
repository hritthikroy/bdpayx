// PM2 Ecosystem Configuration for Production
module.exports = {
  apps: [{
    name: 'bdpayx-backend',
    script: './backend/src/server.js',
    instances: 2, // Use 2 instances for load balancing
    exec_mode: 'cluster',
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/pm2-error.log',
    out_file: './logs/pm2-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    max_memory_restart: '500M',
    autorestart: true,
    watch: false,
    ignore_watch: ['node_modules', 'logs', 'uploads'],
    max_restarts: 10,
    min_uptime: '10s',
    listen_timeout: 3000,
    kill_timeout: 5000
  }]
};
