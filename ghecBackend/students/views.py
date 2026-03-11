import json
import base64
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.base import ContentFile
from .models import Student, Subject

# 🔐 Simple API token
API_TOKEN = "ghec_secret_123"


def check_auth(request):
    token = request.headers.get("Authorization")
    if token != f"Bearer {API_TOKEN}":
        return False
    return True


@csrf_exempt
def add_student(request):

    # 🔐 Authentication check
    if not check_auth(request):
        return JsonResponse({"error": "Unauthorized"}, status=401)

    if request.method != "POST":
        return JsonResponse({"error": "Only POST method allowed"}, status=405)

    try:
        data = json.loads(request.body)

        # 🔹 Required fields check
        required_fields = ['roll', 'name', 'branch', 'gender', 'dob']
        for field in required_fields:
            if not data.get(field):
                return JsonResponse({"error": f"{field} is required"}, status=400)

        # 🔹 Duplicate roll check
        if Student.objects.filter(roll_num=data['roll']).exists():
            return JsonResponse({"error": "Roll number already exists"}, status=400)

        # 🔹 Image handling (optional base64)
        image_data = data.get("image")
        student_image = None

        if image_data:
            try:
                format, imgstr = image_data.split(';base64,')

                # 🔐 Image size limit (5MB)
                if len(imgstr) > 5_000_000:
                    return JsonResponse({"error": "Image too large"}, status=400)

                ext = format.split('/')[-1]
                student_image = ContentFile(
                    base64.b64decode(imgstr),
                    name=f"{data['roll']}.{ext}"
                )

            except Exception:
                return JsonResponse({"error": "Invalid image data"}, status=400)

        student = Student(
            roll_num=data['roll'],
            full_name=data['name'],
            branch=data['branch'],
            semester=int(data.get('semester', 0)),
            admission_year=int(data.get('admission_year', 0)),
            parent_name=data.get('parent_name', ''),
            parent_phone=data.get('parent_phone', ''),
            student_phone=data.get('student_phone', ''),
            email=data.get('email', ''),
            gender=data['gender'],
            date_of_birth=data['dob'],
            address=data.get('address', ''),
            image=student_image
        )

        student.save()

        return JsonResponse({"success": True})

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)


# 🔽 Fetch Students API
def fetch_students_api(request):
    branches = request.GET.get('branches', '')
    semesters = request.GET.get('semesters', '')

    branches_list = branches.split(',') if branches else []
    semesters_list = [int(s) for s in semesters.split(',')] if semesters else []

    students = Student.objects.all()

    if branches_list:
        students = students.filter(branch__in=branches_list)

    if semesters_list:
        students = students.filter(semester__in=semesters_list)

    attendance_count = 20

    data = [
        {
            "roll_num": s.roll_num,
            "full_name": s.full_name,
            "branch": s.branch,
            "semester": s.semester,
            "attendance_count": attendance_count
        }
        for s in students
    ]

    return JsonResponse(data, safe=False)


# 🔽 Get Subjects API
def get_subjects(request):
    branch = request.GET.get('branch')
    semester = request.GET.get('semester')

    if not branch or not semester:
        return JsonResponse({"error": "Branch and semester required"}, status=400)

    subjects = Subject.objects.filter(
        branch=branch,
        semester=semester
    ).values('subject_id', 'sub_name')

    return JsonResponse(list(subjects), safe=False)