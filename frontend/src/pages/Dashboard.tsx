import React from 'react';
import { Users, Server, TrendingUp, Download, Upload } from 'lucide-react';
import TrafficChart from '../components/Dashboard/TrafficChart';
import ServerStatus from '../components/Dashboard/ServerStatus';

const Dashboard: React.FC = () => {
  const stats = {
    totalUsers: 1250,
    activeUsers: 984,
    totalServers: 12,
    onlineServers: 10,
    totalTraffic: '15.2 TB',
    uploadSpeed: '125 Mbps',
    downloadSpeed: '89 Mbps'
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
          Панель управления
        </h1>
        <p className="text-gray-600 dark:text-gray-400">
          Обзор состояния VPN системы
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="p-2 bg-blue-100 dark:bg-blue-900 rounded-lg">
              <Users className="text-blue-600 dark:text-blue-300" size={24} />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600 dark:text-gray-400">
                Всего пользователей
              </p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {stats.totalUsers}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="p-2 bg-green-100 dark:bg-green-900 rounded-lg">
              <Server className="text-green-600 dark:text-green-300" size={24} />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600 dark:text-gray-400">
                Активные серверы
              </p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {stats.onlineServers}/{stats.totalServers}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="p-2 bg-purple-100 dark:bg-purple-900 rounded-lg">
              <Upload className="text-purple-600 dark:text-purple-300" size={24} />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600 dark:text-gray-400">
                Скорость загрузки
              </p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {stats.downloadSpeed}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <div className="flex items-center">
            <div className="p-2 bg-orange-100 dark:bg-orange-900 rounded-lg">
              <Download className="text-orange-600 dark:text-orange-300" size={24} />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600 dark:text-gray-400">
                Скорость отдачи
              </p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {stats.uploadSpeed}
              </p>
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <TrafficChart />
        <ServerStatus />
      </div>
    </div>
  );
};

export default Dashboard;
