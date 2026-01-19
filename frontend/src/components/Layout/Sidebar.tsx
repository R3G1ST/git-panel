import React, { useState } from 'react';
import { NavLink } from 'react-router-dom';
import { 
  Users, 
  Server, 
  BarChart3, 
  CreditCard, 
  Settings, 
  Shield,
  Key,
  Menu,
  X 
} from 'lucide-react';

const Sidebar: React.FC = () => {
  const [isCollapsed, setIsCollapsed] = useState(false);

  const navigation = [
    { name: 'Панель управления', href: '/', icon: BarChart3 },
    { name: 'Пользователи', href: '/users', icon: Users },
    { name: 'Серверы', href: '/servers', icon: Server },
    { name: 'Биллинг', href: '/billing', icon: CreditCard },
    { name: 'API Keys', href: '/api-keys', icon: Key },
    { name: 'Настройки', href: '/settings', icon: Settings },
    { name: 'Безопасность', href: '/security', icon: Shield },
  ];

  return (
    <>
      <div className="lg:hidden">
        <button
          onClick={() => setIsCollapsed(!isCollapsed)}
          className="p-2 m-2 rounded-lg bg-gray-200 dark:bg-gray-700"
        >
          {isCollapsed ? <X size={20} /> : <Menu size={20} />}
        </button>
      </div>

      <div className={`
        fixed lg:static inset-y-0 left-0 z-50
        w-64 bg-white dark:bg-gray-800 shadow-lg
        transform transition-transform duration-300
        ${isCollapsed ? '-translate-x-full lg:translate-x-0' : 'translate-x-0'}
        lg:flex lg:flex-col
      `}>
        <div className="flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-700">
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
              <Shield className="text-white" size={20} />
            </div>
            <span className="text-xl font-bold text-gray-800 dark:text-white">
              Xferant VPN
            </span>
          </div>
        </div>

        <nav className="flex-1 px-4 py-6 space-y-2">
          {navigation.map((item) => (
            <NavLink
              key={item.name}
              to={item.href}
              className={({ isActive }) => `
                flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors
                ${isActive
                  ? 'bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-300'
                  : 'text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-700'
                }
              `}
            >
              <item.icon size={20} className="mr-3" />
              {item.name}
            </NavLink>
          ))}
        </nav>

        <div className="p-4 border-t border-gray-200 dark:border-gray-700">
          <div className="text-xs text-gray-500 dark:text-gray-400">
            Версия: 1.0.0
          </div>
        </div>
      </div>
    </>
  );
};

export default Sidebar;
