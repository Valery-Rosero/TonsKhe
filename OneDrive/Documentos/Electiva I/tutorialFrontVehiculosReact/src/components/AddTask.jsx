import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const AddTask = () => {
    const [task, setTask] = useState({
        nombre: '',
        descripcion: '',
        categoria: 'PENDIENTE',
        estado: 'NUEVO'
    });
    
    const [errors, setErrors] = useState({});
    const [isSubmitting, setIsSubmitting] = useState(false);
    const navigate = useNavigate();

    const handleChange = (e) => {
        const { name, value } = e.target;
        setTask(prev => ({
            ...prev,
            [name]: value
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setIsSubmitting(true);
        setErrors({});

        try {
            const response = await axios.post('http://localhost:8000/tareas/', task);
            
            if (response.status === 201) {
                navigate('/');
            }
        } catch (error) {
            if (error.response && error.response.data) {
                setErrors(error.response.data);
            } else {
                setErrors({ general: 'Error al conectar con el servidor' });
            }
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md">
            <h2 className="text-2xl font-bold mb-4 text-gray-800">Agregar Nueva Tarea</h2>

            {errors.general && (
                <div className="mb-4 p-3 bg-red-100 text-red-700 rounded">
                    {errors.general}
                </div>
            )}

            <form onSubmit={handleSubmit}>
                <div className="mb-4">
                    <label htmlFor="nombre" className="block text-gray-700 text-sm font-bold mb-2">
                        Nombre de la Tarea
                    </label>
                    <input
                        type="text"
                        id="nombre"
                        name="nombre"
                        value={task.nombre}
                        onChange={handleChange}
                        required
                        className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                    />
                    {errors.nombre && <p className="text-red-500 text-xs italic">{errors.nombre}</p>}
                </div>

                <div className="mb-4">
                    <label htmlFor="descripcion" className="block text-gray-700 text-sm font-bold mb-2">
                        Descripción
                    </label>
                    <textarea
                        id="descripcion"
                        name="descripcion"
                        value={task.descripcion}
                        onChange={handleChange}
                        rows="4"
                        required
                        className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                    ></textarea>
                    {errors.descripcion && <p className="text-red-500 text-xs italic">{errors.descripcion}</p>}
                </div>

                <div className="mb-4">
                    <label htmlFor="categoria" className="block text-gray-700 text-sm font-bold mb-2">
                        Categoría
                    </label>
                    <select
                        id="categoria"
                        name="categoria"
                        value={task.categoria}
                        onChange={handleChange}
                        className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                    >
                        <option value="URGENTE">Urgente</option>
                        <option value="PENDIENTE">Pendiente</option>
                        <option value="OPCIONAL">Opcional</option>
                    </select>
                </div>

                <div className="flex items-center justify-between">
                    <button
                        type="submit"
                        disabled={isSubmitting}
                        className={`bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline ${
                            isSubmitting ? 'opacity-50 cursor-not-allowed' : ''
                        }`}
                    >
                        {isSubmitting ? 'Guardando...' : 'Guardar Tarea'}
                    </button>
                    <button
                        type="button"
                        onClick={() => navigate('/')}
                        className="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
                    >
                        Cancelar
                    </button>
                </div>
            </form>
        </div>
    );
};

export default AddTask;