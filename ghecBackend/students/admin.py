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



# admin.site.register(ProfileUpdateRequest)

@admin.register(ProfileUpdateRequest)
class ProfileUpdateRequestAdmin(admin.ModelAdmin):
    # 🔹 Columns to show in admin list view
    list_display = (
        "id",
        "student",           # Student object __str__ se naam aur roll
        "field_name",        # Kaunsa field change ho raha hai
        "old_value",         # Purani value
        "new_value",         # Nayi value
        "status",            # Pending / Approved / Rejected
        "requested_at",      # Request kab ki gayi
        "reviewed_at",       # Kab review kiya gaya
        "reviewed_by",       # Kaun review kiya
    )

    # 🔹 Clickable fields to go to detail view
    list_display_links = ("id", "student")

    # 🔹 Filters on sidebar
    list_filter = ("status", "field_name", "requested_at", "reviewed_by")

    # 🔹 Search bar for admin
    search_fields = (
        "student__full_name",
        "student__roll_num",
        "field_name",
        "status",
        "reviewed_by__full_name",
    )

    # 🔹 Order newest first
    ordering = ("-requested_at",)

    # 🔹 Optional: only show pending by default
    # def get_queryset(self, request):
    #     qs = super().get_queryset(request)
    #     return qs.filter(status="pending")
