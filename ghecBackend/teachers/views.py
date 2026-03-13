import json
import base64
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.base import ContentFile
@csrf_exempt
def addTeacherApi(request):
 print("Done bahi pounch gya url pe..!")
