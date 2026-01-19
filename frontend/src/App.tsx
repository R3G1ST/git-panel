import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout/Layout';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import ApiKeys from './pages/ApiKeys';
import Settings from './pages/Settings';

const App: React.FC = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Dashboard />} />
          <Route path="users" element={<Users />} />
          <Route path="api-keys" element={<ApiKeys />} />
          <Route path="settings" element={<Settings />} />
          <Route path="servers" element={<div>Servers Page</div>} />
          <Route path="billing" element={<div>Billing Page</div>} />
          <Route path="security" element={<div>Security Page</div>} />
        </Route>
      </Routes>
    </Router>
  );
};

export default App;