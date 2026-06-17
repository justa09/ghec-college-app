import json
import base64

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.base import ContentFile
from django.contrib.auth import get_user_model
from django.db import transaction

from .models import Student, Subject

API_TOKEN = "ghec_secret_123"


def check_auth(request):
    token = request.headers.get("Authorization")
    return token == f"Bearer {API_TOKEN}"


@csrf_exempt
def add_student(request):
    if not check_auth(request):
        return JsonResponse({
            "status": "error",
            "message": "Unauthorized"
        }, status=401)

    if request.method != "POST":
        return JsonResponse({
            "status": "error",
            "message": "Only POST method allowed"
        }, status=405)

    try:
        data = json.loads(request.body)

        required_fields = [
            "username",
            "password",
            "roll",
            "name",
            "branch",
            "gender",
            "dob"
        ]

        for field in required_fields:
            if not data.get(field):
                return JsonResponse({
                    "status": "error",
                    "message": f"{field} is required"
                }, status=400)

        username = str(data["username"]).strip()
        password = data["password"]
        roll = str(data["roll"]).strip()

        if username != roll:
            return JsonResponse({
                "status": "error",
                "message": "Username and roll number must be same"
            }, status=400)

        User = get_user_model()

        if User.objects.filter(username=username).exists():
            return JsonResponse({
                "status": "error",
                "message": "User already exists with this roll number"
            }, status=400)

        if Student.objects.filter(roll_num=roll).exists():
            return JsonResponse({
                "status": "error",
                "message": "Roll number already exists"
            }, status=400)

        image_data = data.get("image")
        student_image = None

        if image_data:
            try:
                format, imgstr = image_data.split(";base64,")

                if len(imgstr) > 5_000_000:
                    return JsonResponse({
                        "status": "error",
                        "message": "Image too large"
                    }, status=400)

                ext = format.split("/")[-1]
                student_image = ContentFile(
                    base64.b64decode(imgstr),
                    name=f"{roll}.{ext}"
                )

            except Exception:
                return JsonResponse({
                    "status": "error",
                    "message": "Invalid image data"
                }, status=400)

        with transaction.atomic():
            user = User.objects.create_user(
                username=username,
                password=password,
                role="student"
            )

            student = Student.objects.create(
                user=user,
                roll_num=roll,
                full_name=data["name"],
                branch=data["branch"],
                semester=int(data.get("semester") or 0),
                admission_year=int(data.get("admission_year") or 0),
                parent_name=data.get("parent_name", ""),
                parent_phone=data.get("parent_phone", ""),
                student_phone=data.get("student_phone", ""),
                email=data.get("email", ""),
                gender=data["gender"],
                date_of_birth=data["dob"],
                address=data.get("address", ""),
                image=student_image
            )

        return JsonResponse({
            "status": "success",
            "message": "Student added successfully",
            "id": student.roll_num,
            "name": student.full_name,
            "role": "student"
        }, status=201)

    except Exception as e:
        return JsonResponse({
            "status": "error",
            "message": str(e)
        }, status=400)


def fetch_students_api(request):
    branches = request.GET.get("branches", "").strip()
    semesters = request.GET.get("semesters", "").strip()
    print(f"Received branches: {branches}, semesters: {semesters}")

    branches_list = []
    semesters_list = []

    # handle branches
    if branches and branches.lower() != "all":
        branches_list = [b.strip() for b in branches.split(",") if b.strip()]

    # handle semesters safely
    if semesters and semesters.lower() != "all":
        try:
            semesters_list = [
                int(s) for s in semesters.split(",") if s.strip().isdigit()
            ]
        except:
            semesters_list = []

    students = Student.objects.all()

    if branches_list:
        students = students.filter(branch__in=branches_list)

    if semesters_list:
        students = students.filter(semester__in=semesters_list)

    data = [
        {
            "roll_num": s.roll_num,
            "full_name": s.full_name,
            "branch": s.branch,
            "semester": s.semester,
            "attendance_count": 20
        }
        for s in students
    ]
    print(len(data))

    return JsonResponse(data, safe=False)

def get_subjects(request):
    branch = request.GET.get("branch")
    semester = request.GET.get("semester")

    if not branch or not semester:
        return JsonResponse({
            "status": "error",
            "message": "Branch and semester required"
        }, status=400)

    subjects = Subject.objects.filter(
        branch=branch,
        semester=semester
    ).values("subject_id", "sub_name")

    return JsonResponse(list(subjects), safe=False)



@csrf_exempt
def delete_student(request):
    roll_num= request.GET.get("roll_num")
    
    if request.method != "DELETE":
        return JsonResponse({
            "status": "error",
            "message": "Only DELETE method allowed"
        }, status=405)

    try:
        student = Student.objects.get(roll_num=roll_num)
        user = student.user
        student.delete()
        user.delete()

        return JsonResponse({
            "status": "success",
            "message": f"Student with roll number {roll_num} deleted successfully"
        })

    except Student.DoesNotExist:
        return JsonResponse({
            "status": "error",
            "message": f"No student found with roll number {roll_num}"
        }, status=404)

    except Exception as e:
        return JsonResponse({
            "status": "error",
            "message": str(e)
        }, status=400)