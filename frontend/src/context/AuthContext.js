// frontend/src/context/AuthContext.js
// authentication context - manages user state and auth operations globally

import React, { createContext, useState, useContext, useEffect } from 'react';
import { authAPI } from '../services/api';

// create context for sharing auth state across components
const AuthContext = createContext();

// custom hook to access auth context - throws error if used outside provider
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

// provider component that wraps app and manages authentication state
export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // check authentication status on initial load
  useEffect(() => {
    checkAuth();
  }, []);

  // verify token validity and fetch current user data
  const checkAuth = async () => {
    const token = localStorage.getItem('token');
    if (token) {
      try {
        // validate token by fetching user data from api
        const response = await authAPI.me();
        setUser(response.data.user);
      } catch (error) {
        // clear invalid token from storage
        localStorage.removeItem('token');
        localStorage.removeItem('user');
      }
    }
    setLoading(false);
  };

  // authenticate user with email and password
  const login = async (email, password) => {
    try {
      const response = await authAPI.login(email, password);
      const { token, user } = response.data;

      // store jwt token and user data in localstorage
      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(user));
      setUser(user);

      return { success: true };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.error || 'Login failed',
      };
    }
  };

  // register new user account
  const signup = async (name, email, password, passwordConfirmation) => {
    try {
      const response = await authAPI.signup(
        name,
        email,
        password,
        passwordConfirmation
      );
      const { token, user } = response.data;

      // store jwt token and user data after successful signup
      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(user));
      setUser(user);

      return { success: true };
    } catch (error) {
      return {
        success: false,
        errors:
          error.response?.data?.errors || ['Signup failed'],
      };
    }
  };

  // clear user session and remove stored credentials
  const logout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setUser(null);
  };

  // context value exposed to consuming components
  const value = {
    user,
    loading,
    isAuthenticated: !!user,
    isAdmin: user?.admin || false,
    login,
    signup,
    logout,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
