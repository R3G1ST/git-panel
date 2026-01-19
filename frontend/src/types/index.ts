export interface User {
  id: string;
  email: string;
  username: string;
  status: 'active' | 'inactive' | 'suspended';
  traffic_limit: number;
  traffic_used: number;
  expire_date: string;
  subscription_type: string;
  created_at: string;
  last_connection?: string;
}

export interface VpnServer {
  id: string;
  name: string;
  hostname: string;
  ip_address: string;
  status: 'online' | 'offline' | 'maintenance';
  location: string;
  protocols: string[];
  load_percentage: number;
  last_update: string;
}

export interface ApiKey {
  id: string;
  name: string;
  key: string;
  secret: string;
  type: 'read' | 'write' | 'admin';
  created_at: string;
  expires_at?: string;
  last_used?: string;
  is_active: boolean;
  permissions: string[];
}

export interface ApiResponse<T> {
  data: T;
  message: string;
  success: boolean;
}
