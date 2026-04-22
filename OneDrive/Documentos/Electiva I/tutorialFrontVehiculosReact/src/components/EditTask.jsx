import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useNavigate, useParams } from 'react-router-dom';

const EditTask = () => {
  const { taskId } = useParams();
  const [task, setTask] = useState({
    nombre: '',
    descripcion: '',
    categoria: 'PENDIENTE',
    estado: 'NUEVO'
  });
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [notFound, setNotFound] = useState(false);
  const navigate = useNavigate();

  // Opciones para los selects
  const categoriaOptions = [
    { value: 'URGENTE', label: 'Urgente' },
    { value: 'PENDIENTE', label: 'Pendiente' },
    { value: 'OPCIONAL', label: 'Opcional' }
  ];

  const estadoOptions = [
    { value: 'NUEVO', label: 'Nuevo' },
    { value: 'EN_PROCESO', label: 'En Proceso' },
    { value: 'FINALIZADO', label: 'Finalizado' }
  ];

  useEffect(() => {
    const fetchTask = async () => {
      try {
        const response = await axios.get(`http://localhost:8000/tareas/${taskId}/`);
        if (response.data) {
          setTask({
            nombre: response.data.nombre,
            descripcion: response.data.descripcion,
            categoria: response.data.categoria,
            estado: response.data.estado
          });
        }
      } catch (error) {
        if (error.response?.status === 404) {
          setNotFound(true);
        } else {
          setErrors({
            general: 'Error al cargar la tarea. Intente nuevamente más tarde.'
          });
        }
      } finally {
        setIsLoading(false);
      }
    };

    if (taskId) {
      fetchTask();
    } else {
      setNotFound(true);
      setIsLoading(false);
    }
  }, [taskId]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setTask(prev => ({
      ...prev,
      [name]: value
    }));
    
    // Limpiar error si existe
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: undefined }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!task.nombre.trim()) {
      newErrors.nombre = 'El nombre es requerido';
    } else if (task.nombre.length > 100) {
      newErrors.nombre = 'El nombre no puede exceder los 100 caracteres';
    }
    
    if (!task.descripcion.trim()) {
      newErrors.descripcion = 'La descripción es requerida';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    setIsSubmitting(true);
    setErrors({});

    try {
      const response = await axios.put(`http://localhost:8000/tareas/${taskId}/`, task);
      if (response.status === 200) {
        navigate('/', { 
          state: { 
            success: true,
            message: 'Tarea actualizada correctamente',
            updatedTask: response.data
          } 
        });
      }
    } catch (error) {
      console.error('Error al actualizar:', error);
      if (error.response) {
        // Manejo de errores del backend
        if (error.response.status === 400) {
          // Errores de validación del servidor
          const serverErrors = error.response.data;
          if (typeof serverErrors === 'object') {
            setErrors(serverErrors);
          } else {
            setErrors({ general: 'Datos inválidos enviados al servidor' });
          }
        } else if (error.response.status === 404) {
          setNotFound(true);
        } else {
          setErrors({ general: 'Error del servidor. Intente nuevamente.' });
        }
      } else {
        setErrors({ general: 'Error de conexión. Verifique su red.' });
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md text-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto"></div>
        <p className="mt-2">Cargando tarea...</p>
      </div>
    );
  }

  if (notFound) {
    return (
      <div className="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md text-center">
        <p className="text-red-500 text-lg font-medium">Tarea no encontrada</p>
        <p className="text-gray-600 mt-2">La tarea que intentas editar no existe o fue eliminada.</p>
        <button
          onClick={() => navigate('/')}
          className="mt-4 bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-4 rounded transition duration-200"
        >
          Volver a la lista de tareas
        </button>
      </div>
    );
  }

  return (
    <div className="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-6 text-gray-800 border-b pb-2">Editar Tarea</h2>

      {errors.general && (
        <div className="mb-4 p-3 bg-red-50 text-red-700 rounded border border-red-200">
          {errors.general}
        </div>
      )}

      <form onSubmit={handleSubmit} noValidate>
        <div className="mb-4">
          <label htmlFor="nombre" className="block text-gray-700 text-sm font-medium mb-1">
            Nombre de la Tarea *
          </label>
          <input
            type="text"
            id="nombre"
            name="nombre"
            value={task.nombre}
            onChange={handleChange}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-1 ${
              errors.nombre 
                ? 'border-red-500 focus:ring-red-500' 
                : 'border-gray-300 focus:ring-blue-500'
            }`}
            maxLength="100"
            required
          />
          {errors.nombre && (
            <p className="mt-1 text-sm text-red-600">{errors.nombre}</p>
          )}
        </div>

        <div className="mb-4">
          <label htmlFor="descripcion" className="block text-gray-700 text-sm font-medium mb-1">
            Descripción *
          </label>
          <textarea
            id="descripcion"
            name="descripcion"
            value={task.descripcion}
            onChange={handleChange}
            rows="4"
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-1 ${
              errors.descripcion 
                ? 'border-red-500 focus:ring-red-500' 
                : 'border-gray-300 focus:ring-blue-500'
            }`}
            required
          />
          {errors.descripcion && (
            <p className="mt-1 text-sm text-red-600">{errors.descripcion}</p>
          )}
        </div>

        <div className="grid grid-cols-2 gap-4 mb-4">
          <div>
            <label htmlFor="categoria" className="block text-gray-700 text-sm font-medium mb-1">
              Categoría
            </label>
            <select
              id="categoria"
              name="categoria"
              value={task.categoria}
              onChange={handleChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
            >
              {categoriaOptions.map(option => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label htmlFor="estado" className="block text-gray-700 text-sm font-medium mb-1">
              Estado
            </label>
            <select
              id="estado"
              name="estado"
              value={task.estado}
              onChange={handleChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
            >
              {estadoOptions.map(option => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="flex justify-end space-x-3 pt-4 border-t">
          <button
            type="button"
            onClick={() => navigate('/')}
            className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            disabled={isSubmitting}
          >
            Cancelar
          </button>
          <button
            type="submit"
            disabled={isSubmitting}
            className={`px-4 py-2 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 ${
              isSubmitting
                ? 'bg-blue-400 cursor-not-allowed'
                : 'bg-blue-600 hover:bg-blue-700'
            }`}
          >
            {isSubmitting ? (
              <span className="flex items-center">
                <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Guardando...
              </span>
            ) : 'Guardar Cambios'}
          </button>
        </div>
      </form>
    </div>
  );
};

export default EditTask;