from django.urls import path
from .views import TareaAPIView

urlpatterns = [

    path('', TareaAPIView.as_view(), name='tarea-list'),  
    path('<int:pk>/', TareaAPIView.as_view(), name='tarea-detail'),  
]