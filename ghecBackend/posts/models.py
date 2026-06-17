from django.db import models
from teachers.models import Teacher


class Post(models.Model):
    username = models.ForeignKey(
        Teacher,
        on_delete=models.CASCADE,
        related_name='posts'
    )

    description = models.TextField()

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    user_id = models.IntegerField(blank=True, null=True)

    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.username} - {self.created_at}"


class PostImage(models.Model):
    post = models.ForeignKey(
        Post,
        on_delete=models.CASCADE,
        related_name='images'
    )

    image = models.ImageField(upload_to='posts/')

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Image for Post {self.post.id}"