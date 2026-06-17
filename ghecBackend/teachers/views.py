from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import get_user_model
from django.db import transaction
from .models import Teacher

@csrf_exempt
def addTeacherApi(request):
    if request.method != "POST":
        return JsonResponse({
            "status": "error",
            "message": "Only POST requests are allowed"
        }, status=405)

    try:
        auth_header = request.headers.get("Authorization")

        if auth_header != "Bearer ghec_secret_123":
            return JsonResponse({
                "status": "error",
                "message": "Unauthorized request"
            }, status=401)

        data = request.POST
        image_file = request.FILES.get("image")

        required_fields = [
            "Tid",
            "password",
            "FullName",
            "Tphone",
            "address",
            "joiningDate",
            "dept",
            "role",
        ]

        for field in required_fields:
            if not data.get(field):
                return JsonResponse({
                    "status": "error",
                    "message": f"{field} is required"
                }, status=400)

        tid = data.get("Tid").strip()
        password = data.get("password").strip()
        full_name = data.get("FullName").strip()
        phone = data.get("Tphone").strip()
        address = data.get("address").strip()
        joining_date = data.get("joiningDate").strip()
        dept = data.get("dept").strip()
        role = data.get("role").strip()

        User = get_user_model()

        # valid_roles = [choice[0] for choice in User.ROLE_CHOICES]

        # if role not in valid_roles:
        #     return JsonResponse({
        #         "status": "error",
        #         "message": "Invalid role"
        #     }, status=400)

        if User.objects.filter(username=tid).exists():
            return JsonResponse({
                "status": "error",
                "message": "Teacher already exists with this Tid"
            }, status=400)

        with transaction.atomic():
            user = User.objects.create_user(
                username=tid,
                password=password
            )

            user.first_name = full_name
            user.role = role
            user.save()

        try:
            teacher = Teacher.objects.create(
            user=user,
            tId=tid,
            full_name=full_name,
            t_phone=phone,
            address=address,
            joining_date=joining_date,
            dept=dept,
            image=image_file)
            print(teacher)
        except Exception as e:
            print(e)
        

        return JsonResponse({
            "status": "success",
            "message": "Teacher added successfully",
            "data": {
                "Tid": tid,
                "FullName": full_name,
                "Tphone": phone,
                "address": address,
                "joiningDate": joining_date,
                "dept": dept,
                "role": user.role,
                "imageUploaded": image_file is not None
            }
        }, status=201)

    except Exception as e:
        return JsonResponse({
            "status": "error",
            "message": str(e)
        }, status=500)
    

def fetchTeacherApi(request):
    if request.method != "GET":
        return JsonResponse({
            "status": "error",
            "message": "Only GET requests are allowed"
        }, status=405)

    try:
        teachers = Teacher.objects.all()
        teacher_list = []

        for teacher in teachers:
            teacher_list.append({
                "Tid": teacher.tId,
                "FullName": teacher.full_name,
                "Tphone": teacher.t_phone,
                "address": teacher.address,
                "joiningDate": teacher.joining_date,
                "dept": teacher.dept,
                "role": teacher.user.role,
                "imageURL": request.build_absolute_uri(teacher.image.url) if teacher.image else None
            })
            

        return JsonResponse({
            "status": "success",
            "message": "Teachers fetched successfully",
            "data": teacher_list
        }, status=200)

    except Exception as e:
        return JsonResponse({
            "status": "error",
            "message": str(e)
        }, status=500)
    


@csrf_exempt
def delete_teacher(request, tid):

    if request.method != "DELETE":
        return JsonResponse({
            "status": "error",
            "message": "Only DELETE requests are allowed"
        }, status=405)

    try:
        
        teacher = Teacher.objects.filter(tId=tid).first()

        if not teacher:
            return JsonResponse({
                "status": "error",
                "message": "Teacher not found"
            }, status=404)

        user = teacher.user

        teacher.delete()

        if user:
            user.delete()

        return JsonResponse({
            "status": "success",
            "message": "Teacher deleted successfully"
        }, status=200)

    except Exception as e:
        return JsonResponse({
            "status": "error",
            "message": str(e)
        }, status=500)