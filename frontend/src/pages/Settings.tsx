import React, { useState, useEffect } from 'react';
import { Save, Database, Server, CreditCard, Shield } from 'lucide-react';

const Settings: React.FC = () => {
  const [settings, setSettings] = useState({
    site_name: 'Xferant VPN',
    support_email: 'support@xferant.com',
    default_traffic_limit: 1073741824,
    max_connections_per_user: 5,
    currency: 'RUB',
    payment_methods: ['sbp', 'card'],
    auto_renewal: true,
    enable_2fa: true,
  });

  const [loading, setLoading] = useState(false);

  const saveSettings = async () => {
    setLoading(true);
    try {
      // API call to save settings
      await new Promise(resolve => setTimeout(resolve, 1000));
      console.log('Settings saved:', settings);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
          Настройки системы
        </h1>
        <button
          onClick={saveSettings}
          disabled={loading}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center"
        >
          <Save size={20} className="mr-2" />
          {loading ? 'Сохранение...' : 'Сохранить настройки'}
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-4">
          <nav className="space-y-2">
            <button className="w-full text-left p-2 rounded bg-blue-50 text-blue-700">
              <Database size={16} className="inline mr-2" />
              Общие настройки
            </button>
            <button className="w-full text-left p-2 rounded hover:bg-gray-100">
              <Server size={16} className="inline mr-2" />
              VPN конфигурация
            </button>
            <button className="w-full text-left p-2 rounded hover:bg-gray-100">
              <CreditCard size={16} className="inline mr-2" />
              Платежные системы
            </button>
            <button className="w-full text-left p-2 rounded hover:bg-gray-100">
              <Shield size={16} className="inline mr-2" />
              Безопасность
            </button>
          </nav>
        </div>

        <div className="md:col-span-3 space-y-6">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold mb-4">Общие настройки</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-2">Название сайта</label>
                <input
                  type="text"
                  value={settings.site_name}
                  onChange={(e) => setSettings({...settings, site_name: e.target.value})}
                  className="input-field"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Email поддержки</label>
                <input
                  type="email"
                  value={settings.support_email}
                  onChange={(e) => setSettings({...settings, support_email: e.target.value})}
                  className="input-field"
                />
              </div>
            </div>
          </div>

          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold mb-4">VPN настройки</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-2">
                  Лимит трафика по умолчанию (GB)
                </label>
                <input
                  type="number"
                  value={settings.default_traffic_limit / 1024 / 1024 / 1024}
                  onChange={(e) => setSettings({...settings, default_traffic_limit: e.target.value * 1024 * 1024 * 1024})}
                  className="input-field"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">
                  Макс. подключений на пользователя
                </label>
                <input
                  type="number"
                  value={settings.max_connections_per_user}
                  onChange={(e) => setSettings({...settings, max_connections_per_user: parseInt(e.target.value)})}
                  className="input-field"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Settings;
