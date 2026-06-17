from django.urls import path
from .views import *  # <-- direct function import

urlpatterns = [
    path("addTeacher/",addTeacherApi, name="addTeachers"),
    path("fetch_teachers/", fetchTeacherApi, name="fetchTeachers"),
    path("delete_teacher/<str:tid>/", delete_teacher, name="deleteTeacher"),
]