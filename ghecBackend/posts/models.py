from django.db import models
from teachers.models import Teacher


class Post(models.Model):

    # 👤 Teacher se relation (username ki jagah proper relation)
    username = models.ForeignKey(Teacher, on_delete=models.CASCADE)

    # 📝 Description
    description = models.TextField()

    # 🖼️ Image
    image = models.ImageField(upload_to='posts/', blank=True, null=True)

    # 🕒 Time fields
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # 👤 Future use (optional)
    user_id = models.IntegerField(blank=True, null=True)

    # ✅ Active status
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.username} - {self.created_at}"

