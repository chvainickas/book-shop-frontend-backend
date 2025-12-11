// frontend/src/services/api.js

import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000/api/v1';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add JWT token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Authentication API
export const authAPI = {
  login: (email, password) =>
    api.post('/auth/login', { user: { email, password } }),

  signup: (name, email, password, passwordConfirmation) =>
    api.post('/auth/signup', {
      user: { name, email, password, password_confirmation: passwordConfirmation },
    }),

  me: () => api.get('/auth/me'),
};

// Books API
export const booksAPI = {
  getAll: (params = {}) => api.get('/books', { params }),
  getById: (id) => api.get(`/books/${id}`),
  create: (bookData) => api.post('/books', { book: bookData }),
  update: (id, bookData) => api.patch(`/books/${id}`, { book: bookData }),
  delete: (id) => api.delete(`/books/${id}`),
};

// Categories API
export const categoriesAPI = {
  getAll: () => api.get('/categories'),
  getById: (id) => api.get(`/categories/${id}`),
};

// Cart API
export const cartAPI = {
  get: () => api.get('/cart'),
  addItem: (bookId, quantity = 1) =>
    api.post('/cart/items', { book_id: bookId, quantity }),
  updateItem: (itemId, quantity) =>
    api.patch(`/cart/items/${itemId}`, { quantity }),
  removeItem: (itemId) => api.delete(`/cart/items/${itemId}`),
  clear: () => api.delete('/cart'),
};

// Orders API
export const ordersAPI = {
  getAll: () => api.get('/orders'),
  getById: (id) => api.get(`/orders/${id}`),
  create: () => api.post('/orders'),
};

// Wishlist API
export const wishlistAPI = {
  get: () => api.get('/wishlist'),
  addItem: (bookId) => api.post('/wishlist/items', { book_id: bookId }),
  removeItem: (itemId) => api.delete(`/wishlist/items/${itemId}`),
};

export default api;
