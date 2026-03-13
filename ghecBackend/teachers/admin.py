from django.contrib import admin
from .models import Teacher

# Register your models here.
@admin.register(Teacher)
class AdminStudent(admin.ModelAdmin):
    list_display=(
        "tId","full_name")