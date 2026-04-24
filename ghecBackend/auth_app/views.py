from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.contrib.auth import authenticate

from students.models import Student
from teachers.models import Teacher


@api_view(['POST'])
def login_api(request):
    username = request.data.get('username', '').strip()
    password = request.data.get('password', '')

    if not username or not password:
        return Response({
            "status": "error",
            "message": "Username and password required"
        }, status=400)

    user = authenticate(username=username, password=password)

    if user is None:
        return Response({
            "status": "error",
            "message": "Invalid credentials"
        }, status=401)

    if user.role == "student":
        try:
            stu = Student.objects.get(user=user)
            image_url = request.build_absolute_uri(stu.image.url) if stu.image else ""

            return Response({
                "status": "success",
                "role": "student",
                "name": stu.full_name,
                "id": stu.roll_num,
                "image": image_url
            }, status=200)

        except Student.DoesNotExist:
            return Response({
                "status": "error",
                "message": "Student profile not found"
            }, status=404)

    if user.role == "teacher":
        try:
            teacher = Teacher.objects.get(user=user)
            image_url = request.build_absolute_uri(teacher.image.url) if teacher.image else ""

            return Response({
                "status": "success",
                "role": "teacher",
                "name": teacher.full_name,
                "id": teacher.tId,
                "image": image_url
            }, status=200)

        except Teacher.DoesNotExist:
            return Response({
                "status": "error",
                "message": "Teacher profile not found"
            }, status=404)

    return Response({
        "status": "error",
        "message": "Invalid role"
    }, status=400)