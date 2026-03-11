# auth/serializers.py
from rest_framework import serializers

class LoginSerializer(serializers.Serializer):
    rollNo = serializers.IntegerField()
    password = serializers.CharField(write_only=True)