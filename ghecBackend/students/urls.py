from django.urls import path,include
from .views import get_subjects, fetch_students_api
from django.conf import settings
from django.conf.urls.static import static
from students import views

urlpatterns = [
    path('get-subjects/', get_subjects),
    path('fetch_students/', fetch_students_api),
    path('get_subjects/', views.get_subjects, name='get_subjects'),
     path('add', views.add_student, name='add_student'),
]

