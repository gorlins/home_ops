#!/usr/bin/env bash

NODES=("talos-w1" "talos-w2" "talos-w3")

read -p "Are you sure you want to continue? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  echo "OKK!"
else
  echo "Exiting"
  exit 0
fi

kubectl --namespace rook-ceph patch cephcluster rook-ceph --type merge -p '{"spec":{"cleanupPolicy":{"confirmation":"yes-really-destroy-data"}}}'
kubectl delete storageclasses ceph-block ceph-bucket ceph-filesystem ceph-rbd cephfs
kubectl --namespace rook-ceph delete cephblockpools ceph-blockpool
kubectl --namespace rook-ceph delete cephobjectstore ceph-objectstore
kubectl --namespace rook-ceph delete cephfilesystem ceph-filesystem
kubectl --namespace rook-ceph delete cephcluster rook-ceph
kubectl --namespace rook-ceph delete clientprofiles rook-ceph
helm --namespace rook-ceph uninstall rook-ceph-cluster
helm --namespace rook-ceph uninstall rook-ceph
kubectl delete crds cephblockpools.ceph.rook.io cephbucketnotifications.ceph.rook.io cephbuckettopics.ceph.rook.io \
                      cephclients.ceph.rook.io cephclusters.ceph.rook.io cephfilesystemmirrors.ceph.rook.io \
                      cephfilesystems.ceph.rook.io cephfilesystemsubvolumegroups.ceph.rook.io \
                      cephnfses.ceph.rook.io cephobjectrealms.ceph.rook.io cephobjectstores.ceph.rook.io \
                      cephobjectstoreusers.ceph.rook.io cephobjectzonegroups.ceph.rook.io cephobjectzones.ceph.rook.io \
                      cephrbdmirrors.ceph.rook.io objectbucketclaims.objectbucket.io objectbuckets.objectbucket.io \
                      cephblockpoolradosnamespaces.ceph.rook.io cephcosidrivers.ceph.rook.io clientprofiles.csi.ceph.io

kubectl delete namespace rook-ceph

for node in "${NODES[@]}"; do
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: disk-clean-$node
spec:
  restartPolicy: Never
  nodeName: $node
  volumes:
  - name: rook-data-dir
    hostPath:
      path: /var/lib/rook
  containers:
  - name: disk-clean
    image: busybox
    securityContext:
      privileged: true
    volumeMounts:
    - name: rook-data-dir
      mountPath: /node/rook-data
    command: ["/bin/sh", "-c", "rm -rf /node/rook-data/*"]
EOF
done

for node in "${NODES[@]}"; do
    kubectl wait --timeout=900s --for=jsonpath='{.status.phase}=Succeeded' pod disk-clean-$node
    kubectl delete pod disk-clean-$node
done
