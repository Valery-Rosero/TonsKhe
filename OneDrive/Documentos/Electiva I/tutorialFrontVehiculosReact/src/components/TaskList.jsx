import { useState, useEffect } from "react";
import api from "../api/axiosConfig";
import AddTask from "./AddTask";
import EditTask from "./EditTask";
import { useNavigate } from "react-router-dom";

const CATEGORIAS = [
  { id: 'TODAS', nombre: 'Todas las categorías' },
  { id: 'URGENTE', nombre: 'Urgentes' },
  { id: 'PENDIENTE', nombre: 'Pendientes' },
  { id: 'OPCIONAL', nombre: 'Opcionales' }
];

const ESTADOS = {
  'NUEVO': 'Nuevo',
  'EN_PROCESO': 'En Proceso',
  'FINALIZADO': 'Finalizado'
};

const TaskList = () => {
  const [tasks, setTasks] = useState([]);
  const navigate = useNavigate();
  const [filteredTasks, setFilteredTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAddTask, setShowAddTask] = useState(false);
  const [selectedTask, setSelectedTask] = useState(null);
  const [selectedCategory, setSelectedCategory] = useState('TODAS');
  const [searchTerm, setSearchTerm] = useState('');
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  useEffect(() => {
    const fetchTasks = async () => {
      try {
        const response = await api.get('tareas/');
        setTasks(response.data);
        setFilteredTasks(response.data);
      } catch (error) {
        console.error("Error fetching tasks:", error);
      } finally {
        setLoading(false);
      }
    };
    fetchTasks();
  }, []);

  useEffect(() => {
    let result = tasks;
    
    if (selectedCategory !== 'TODAS') {
      result = result.filter(task => task.categoria === selectedCategory);
    }
    
    if (searchTerm) {
      result = result.filter(task => 
        task.nombre.toLowerCase().includes(searchTerm.toLowerCase()) ||
        task.descripcion.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    
    setFilteredTasks(result);
  }, [selectedCategory, tasks, searchTerm]);

  const handleDelete = async (id) => {
    if (!window.confirm("¿Estás seguro de eliminar esta tarea?")) return;
    
    try {
      await api.delete(`api/tareas/${id}/`);
      setTasks(tasks.filter(task => task.id !== id));
    } catch (error) {
      console.error("Error deleting task:", error);
      alert("No se pudo eliminar la tarea");
    }
  };

  const handleAddTask = (newTask) => {
    setTasks([...tasks, newTask]);
    setShowAddTask(false);
  };

  const handleUpdateTask = (updatedTask) => {
    setTasks(tasks.map(task => 
      task.id === updatedTask.id ? updatedTask : task
    ));
    setSelectedTask(null);
  };

  const toggleTaskStatus = async (taskId) => {
    try {
      const response = await api.patch(`/tareas/${taskId}/`, { estado: 'toggle' });
      setTasks(tasks.map(task => 
        task.id === taskId ? response.data : task
      ));
    } catch (error) {
      console.error("Error toggling task status:", error);
    }
  };

  const getEstadoStyles = (estado) => {
    const styles = {
      'NUEVO': 'bg-blue-100 text-blue-800 border border-blue-200',
      'EN_PROCESO': 'bg-yellow-100 text-yellow-800 border border-yellow-200',
      'FINALIZADO': 'bg-green-100 text-green-800 border border-green-200'
    };
    return styles[estado] || 'bg-gray-100 text-gray-800 border border-gray-200';
  };

  const getCategoryColor = (categoria) => {
    const colors = {
      'URGENTE': 'bg-red-100 text-red-800 border border-red-200',
      'PENDIENTE': 'bg-orange-100 text-orange-800 border border-orange-200',
      'OPCIONAL': 'bg-green-100 text-green-800 border border-green-200'
    };
    return colors[categoria] || 'bg-gray-100 text-gray-800 border border-gray-200';
  };

  if (loading) return (
    <div className="flex justify-center items-center h-screen">
      <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
    </div>
  );

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Gestión de Tareas</h1>
          <p className="text-gray-600 mt-1">Administra todas las tareas del sistema</p>
        </div>
        
        <button
            onClick={() => navigate('/add-task')}
            className="flex items-center bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors mt-4 md:mt-0 shadow-sm"
        >
            <span className="mr-2">+</span>
            Añadir Tarea
        </button>
      </div>

      <div className="bg-white p-4 rounded-lg shadow mb-6 border border-gray-200">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="relative flex-1">
            <input
              type="text"
              placeholder="Buscar tareas por nombre o descripción..."
              className="pl-4 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          
          <div className="relative">
            <button
              onClick={() => setIsDropdownOpen(!isDropdownOpen)}
              className="flex items-center justify-between px-4 py-2 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 w-full md:w-64"
            >
              <div className="flex items-center">
                <span className="mr-2 text-gray-400">⏫</span>
                <span>{CATEGORIAS.find(c => c.id === selectedCategory)?.nombre}</span>
              </div>
              <span className={`ml-2 transition-transform ${isDropdownOpen ? 'transform rotate-180' : ''}`}>▼</span>
            </button>
            
            {isDropdownOpen && (
              <div className="absolute z-10 mt-1 w-full md:w-64 bg-white border border-gray-300 rounded-lg shadow-lg">
                {CATEGORIAS.map((cat) => (
                  <button
                    key={cat.id}
                    onClick={() => {
                      setSelectedCategory(cat.id);
                      setIsDropdownOpen(false);
                    }}
                    className={`block w-full text-left px-4 py-2 hover:bg-gray-50 ${
                      selectedCategory === cat.id ? 'bg-blue-500 text-white font-medium' : 'text-gray-700'
                    }`}
                  >
                    {cat.nombre}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden border border-gray-200">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Tarea</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Categoría</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Descripción</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Estado</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredTasks.length > 0 ? (
                filteredTasks.map((task) => (
                  <tr key={task.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="font-medium text-gray-900">{task.nombre}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-3 py-1 text-xs rounded-full ${getCategoryColor(task.categoria)}`}>
                        {task.categoria_nombre || task.categoria}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-500 max-w-xs">
                      <div className="line-clamp-2">{task.descripcion}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <button 
                        onClick={() => toggleTaskStatus(task.id)}
                        className={`px-3 py-1 text-xs font-medium rounded-full ${getEstadoStyles(task.estado)} cursor-pointer`}
                      >
                        {task.estado_nombre || ESTADOS[task.estado] || task.estado}
                      </button>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex space-x-2">
                        <button 
                          onClick={() => setSelectedTask(task)}
                          className="text-blue-600 hover:text-blue-800 p-2 rounded hover:bg-blue-50 transition-colors"
                          title="Editar"
                        >
                          ✏️ Editar
                        </button>
                        <button 
                          onClick={() => handleDelete(task.id)}
                          className="text-red-600 hover:text-red-800 p-2 rounded hover:bg-red-50 transition-colors"
                          title="Eliminar"
                        >
                          🗑️ Eliminar
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={5} className="px-6 py-4 text-center text-gray-500">
                    No se encontraron tareas
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {showAddTask && (
        <AddTask 
          onClose={() => setShowAddTask(false)}
          onAdd={handleAddTask}
          categorias={CATEGORIAS.filter(cat => cat.id !== 'TODAS')}
        />
      )}
      
      {selectedTask && (
        <EditTask 
          task={selectedTask}
          onClose={() => setSelectedTask(null)}
          onEdit={handleUpdateTask}
          categorias={CATEGORIAS.filter(cat => cat.id !== 'TODAS')}
        />
      )}
    </div>
  );
};

export default TaskList;