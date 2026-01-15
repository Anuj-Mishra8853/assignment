#!/bin/bash

echo "=== RBAC Testing Script ==="
echo

# Test 1: List all namespaces (should succeed)
echo "1. Testing: List all namespaces (should SUCCEED)"
kubectl get namespaces
echo "Status: $?"
echo

# Test 2: List pods in default namespace (should fail)
echo "2. Testing: List pods in default namespace (should FAIL)"
kubectl get pods -n default 2>&1
echo "Status: $?"
echo

# Test 3: List pods in kube-system (should fail)
echo "3. Testing: List pods in kube-system (should FAIL)"
kubectl get pods -n kube-system 2>&1
echo "Status: $?"
echo

# Test 4: List pods in rbac-a (should succeed)
echo "4. Testing: List pods in rbac-a (should SUCCEED)"
kubectl get pods -n rbac-a
echo "Status: $?"
echo

# Test 5: Create deployment in rbac-a (should fail - read-only)
echo "5. Testing: Create deployment in rbac-a (should FAIL - read-only)"
kubectl create deployment test-deploy --image=nginx -n rbac-a 2>&1
echo "Status: $?"
echo

# Test 6: List pods in rbac-b (should succeed)
echo "6. Testing: List pods in rbac-b (should SUCCEED)"
kubectl get pods -n rbac-b
echo "Status: $?"
echo

# Test 7: Create deployment in rbac-b (should succeed)
echo "7. Testing: Create deployment in rbac-b (should SUCCEED)"
kubectl create deployment test-deploy --image=nginx -n rbac-b
echo "Status: $?"
echo

# Test 8: Delete deployment in rbac-b (should succeed)
echo "8. Testing: Delete deployment in rbac-b (should SUCCEED)"
kubectl delete deployment test-deploy -n rbac-b
echo "Status: $?"
echo

echo "=== RBAC Testing Complete ==="
