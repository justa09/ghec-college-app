from django.urls import path
from .views import submit_attendance, showAttendance

urlpatterns = [
    # 🔹 Submit attendance
    path('attendance/', submit_attendance, name='submit_attendance'),

    # 🔹 Show attendance (fetch for roll numbers)
    path('attendance/show/', showAttendance, name='show_attendance'),
]