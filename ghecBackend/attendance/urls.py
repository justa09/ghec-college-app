from django.urls import path
from .views import submit_attendance, showAttendance,send_sms

urlpatterns = [
    # 🔹 Submit attendance
    path('attendance/', submit_attendance, name='submit_attendance'),

    # 🔹 Show attendance (fetch for roll numbers)
    path('attendance/show/', showAttendance, name='show_attendance'),
    path('send/', showAttendance, name='send_sms'),
]