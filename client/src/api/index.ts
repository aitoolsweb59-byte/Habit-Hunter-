import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || '/api',
});

api.interceptors.request.use(async (config) => {
  try {
    const token = await (window as any).__clerk_frontend_api?.session?.getToken();
    if (token) config.headers.Authorization = `Bearer ${token}`;
  } catch {}
  return config;
});

export const habitsApi = {
  getAll: () => api.get('/habits'),
  create: (data: any) => api.post('/habits', data),
  update: (id: number, data: any) => api.put(`/habits/${id}`, data),
  delete: (id: number) => api.delete(`/habits/${id}`),
  complete: (id: number) => api.post(`/habits/${id}/complete`),
  getStats: (id: number) => api.get(`/habits/${id}/stats`),
};

export const categoriesApi = {
  getAll: () => api.get('/categories'),
  create: (data: any) => api.post('/categories', data),
  update: (id: number, data: any) => api.put(`/categories/${id}`, data),
  delete: (id: number) => api.delete(`/categories/${id}`),
};

export default api;
