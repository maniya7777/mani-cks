#!/bin/bash

echo "==============================================="
echo " QUESTION"
echo "==============================================="

echo
echo "A misbehaving Pod poses a security threat to the system."
echo
echo "Task"
echo "A Pod belonging to the ollama application is abnormal — it is directly accessing system memory by reading from the sensitive file /dev/mem."
echo
echo "First, identify the misbehaving Pod accessing /dev/mem."
echo "Next, scale the Deployment of the misbehaving Pod to zero replicas."
echo
echo "==============================================="

echo
echo "Environment setup completed."
echo
echo "Suggested approach:"
echo "1. Gain root access."
echo "2. Check the deployments."
echo "3. Create a Falco rule to detect access to /dev/mem."
echo "4. Monitor for 30 seconds and save the alerts to a file."
echo "5. Review the Falco logs."
echo "6. Identify the offending container using crictl or Docker commands."
echo "7. Scale the corresponding Deployment to zero replicas."
