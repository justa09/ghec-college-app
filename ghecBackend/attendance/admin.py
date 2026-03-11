from django.contrib import admin
from .models import *

# Register your models here.


@admin.register(Attendance)
class AttendanceAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "student",
        "subject",
        "date",
        "status",
        "lecture_no",
    )
    
    list_filter = (
        "subject",
        "date",
        "status",
    )

    search_fields = (
        "student__full_name",
        "student__roll_num",
        "subject__name",
    )
