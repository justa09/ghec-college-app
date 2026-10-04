from django.contrib import admin
from django.urls import path, include
from students.views import fetch_students_api
from django.conf import settings
from django.conf.urls.static import static
from attendance.views import send_sms


urlpatterns = [
    path('admin/', admin.site.urls),

    # Auth
    path('api/auth/', include('auth_app.urls')),

    # Students
    path('api/fetch_students/', fetch_students_api),
    path('api/', include('students.urls')),
    path('students/', include('students.urls')),

    # Teachers
    path('api/', include('teachers.urls')),

    # Attendance
    path('api/', include('attendance.urls')),

    # Posts
    path('api/posts/', include('posts.urls')),

    # SMS
    path('send/', send_sms),

    # Student / Teacher APIs
    path('api/delete_student/', include('students.urls')),
    path('api/fetch_teachers/', include('teachers.urls')),
    path('api/delete_teacher/', include('teachers.urls')),

    # Attendance records
    path('showRecords/', include('attendance.urls')),
]


# Media files serve karne ke liye (development only)
if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL,
        document_root=settings.MEDIA_ROOT
    )