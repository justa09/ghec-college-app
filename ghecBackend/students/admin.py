from django.contrib import admin
from .models import *

# Register your models here.


@admin.register(Student)
class AdminStudent(admin.ModelAdmin):
    list_display=(
        "roll_num","full_name","branch","semester")
    
@admin.register(Subject)
class Subject(admin.ModelAdmin):
    list_display=( "subject_id","sub_name","branch","semester")

