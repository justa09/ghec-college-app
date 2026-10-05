from django.contrib import admin
from django.urls import path, include, re_path
from students.views import fetch_students_api
from django.conf import settings
from attendance.views import send_sms
from django.views.generic import TemplateView
from django.views.static import serve


urlpatterns = [
    path(
        'google58f17756131275a9.html',
        TemplateView.as_view(
            template_name='google58f17756131275a9.html'
        ),
    ),

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


# Media files serve karne ke liye
urlpatterns += [
    re_path(
        r"^media/(?P<path>.*)$",
        serve,
        {
            "document_root": settings.MEDIA_ROOT,
        },
    ),
]