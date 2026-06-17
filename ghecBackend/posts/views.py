from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import Post, PostImage
from teachers.models import Teacher


@csrf_exempt
def create_post(request):
    print("Received request to create post..!")
    if request.method != "POST":
        return JsonResponse({"error": "Only POST allowed"}, status=405)

    try:
        teacher_id = request.POST.get("teacher_id")
        description = request.POST.get("description")
        images = request.FILES.getlist("images")

        if not teacher_id or not description:
            return JsonResponse({"error": "Missing fields"}, status=400)

        try:
            # ✅ FIX: id → tId
            teacher = Teacher.objects.get(tId=teacher_id)
        except Teacher.DoesNotExist:
            return JsonResponse({"error": "Teacher not found"}, status=404)

        post = Post.objects.create(
            username=teacher,
            description=description
        )

        for image in images:
            PostImage.objects.create(
                post=post,
                image=image
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
        posts = Post.objects.filter(is_active=True).order_by("-created_at")

        data = []
        for post in posts:
            data.append({
                "id": post.id,
                "username": post.username.full_name,
                "description": post.description,
                "images": [
                    request.build_absolute_uri(img.image.url)
                    for img in post.images.all()
                ],
                "created_at": post.created_at.strftime("%Y-%m-%d %H:%M")
            })

        return JsonResponse(data, safe=False)

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)