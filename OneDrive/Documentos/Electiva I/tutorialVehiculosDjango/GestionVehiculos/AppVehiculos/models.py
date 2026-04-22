from django.db import models


class Tarea(models.Model):
    CATEGORIA_CHOICES = [
        ('URGENTE', 'Urgente'),
        ('PENDIENTE', 'Pendiente'),
        ('OPCIONAL', 'Opcional'),
    ]
    
    ESTADO_CHOICES = [
        ('NUEVO', 'Nuevo'),
        ('EN_PROCESO', 'En Proceso'),
        ('FINALIZADO', 'Finalizado'),
    ]

    categoria = models.CharField(max_length=20, choices=CATEGORIA_CHOICES)
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField()
    estado = models.CharField(
        max_length=20, 
        choices=ESTADO_CHOICES, 
        default='NUEVO'
    )

    def __str__(self):
        return f"{self.nombre} ({self.get_categoria_display()})"

    class Meta:
        verbose_name = "Tarea"
        verbose_name_plural = "Tareas"
        ordering = ['categoria', 'nombre']