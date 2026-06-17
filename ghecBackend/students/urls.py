from django.urls import path,include
from .views import get_subjects, fetch_students_api
from django.conf import settings
from django.conf.urls.static import static
from students import views
from .request_views import create_update_request, get_all_requests, handle_request

urlpatterns = [
    path('get-subjects/', get_subjects),
    path('fetch_students/', fetch_students_api),
    path('get_subjects/', views.get_subjects, name='get_subjects'),
     path('add', views.add_student, name='add_student'),
      path('request/create/', create_update_request),
    path('request/all/', get_all_requests),
    path('request/<int:request_id>/', handle_request),
    path('api/fetch_students/', fetch_students_api, name='fetch_students_api'),
    path('delete_student/', views.delete_student, name='delete_student'),
]


