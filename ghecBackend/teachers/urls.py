from django.urls import path
from .views import addTeacherApi  # <-- direct function import

urlpatterns = [
    path("addTeacher/",addTeacherApi, name="addTeachers"),
]