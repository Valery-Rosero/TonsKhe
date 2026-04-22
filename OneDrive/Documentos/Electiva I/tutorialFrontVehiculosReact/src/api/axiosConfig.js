// src/api/axiosConfig.js
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8000/', // << tu backend debe tener esta ruta raíz
  headers: {
    'Content-Type': 'application/json'
  }
});

export default api;
