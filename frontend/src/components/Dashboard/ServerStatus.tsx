import React from 'react';
import { Server, CheckCircle, XCircle, Clock } from 'lucide-react';

const ServerStatus: React.FC = () => {
  const servers = [
    { name: 'New York', status: 'online', load: 45 },
    { name: 'London', status: 'online', load: 32 },
    { name: 'Tokyo', status: 'offline', load: 0 },
    { name: 'Singapore', status: 'online', load: 67 },
  ];

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'online': return <CheckCircle className="text-green-500" size={20} />;
      case 'offline': return <XCircle className="text-red-500" size={20} />;
      default: return <Clock className="text-yellow-500" size={20} />;
    }
  };

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
      <h3 className="text-lg font-semibold mb-4">Статус серверов</h3>
      <div className="space-y-3">
        {servers.map((server) => (
          <div key={server.name} className="flex items-center justify-between p-3 border rounded-lg">
            <div className="flex items-center space-x-3">
              <Server size={20} className="text-gray-400" />
              <span className="font-medium">{server.name}</span>
            </div>
            <div className="flex items-center space-x-3">
              <div className="w-20 bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                <div 
                  className={`h-2 rounded-full ${
                    server.load < 50 ? 'bg-green-500' : 
                    server.load < 80 ? 'bg-yellow-500' : 'bg-red-500'
                  }`}
                  style={{ width: `${server.load}%` }}
                />
              </div>
              <span className="text-sm text-gray-500">{server.load}%</span>
              {getStatusIcon(server.status)}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ServerStatus;
