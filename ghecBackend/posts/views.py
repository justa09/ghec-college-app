
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from .models import Post
from teachers.models import Teacher


@csrf_exempt
def create_post(request):
    if request.method != "POST":
        return JsonResponse({"error": "Only POST allowed"}, status=405)

    try:
        data = json.loads(request.body)

        teacher_id = data.get("teacher_id")
        description = data.get("description")

        if not teacher_id or not description:
            return JsonResponse({"error": "Missing fields"}, status=400)

        try:
            teacher = Teacher.objects.get(id=teacher_id)
        except Teacher.DoesNotExist:
            return JsonResponse({"error": "Teacher not found"}, status=404)

        post = Post.objects.create(
            username=teacher,
            description=description
        )

        return JsonResponse({
            "message": "Post created successfully",
            "post_id": post.id
        }, status=201)

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)
    



@csrf_exempt
def get_posts(request):
    if request.method != "GET":
        return JsonResponse({"error": "Only GET allowed"}, status=405)

    try:
        posts = Post.objects.filter(is_active=True).order_by('-created_at')

        data = []
        for post in posts:
            data.append({
                "id": post.id,
                "username": post.username.full_name,  # teacher ka naam
                "description": post.description,
                "image": post.image.url if post.image else None,
                "created_at": post.created_at.strftime("%Y-%m-%d %H:%M")
            })

        return JsonResponse(data, safe=False)

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)
