import React from 'react';
import { Key, Plus } from 'lucide-react';

const ApiKeys: React.FC = () => {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
            API Keys Management
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            Create and manage API keys for integrations
          </p>
        </div>
        <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg flex items-center">
          <Plus size={20} className="mr-2" />
          Create API Key
        </button>
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div className="text-center py-12">
          <Key className="mx-auto text-gray-400" size={48} />
          <p className="mt-4 text-gray-600 dark:text-gray-400">
            No API keys created yet
          </p>
          <button className="mt-4 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg">
            Create your first API key
          </button>
        </div>
      </div>
    </div>
  );
};

export default ApiKeys;
