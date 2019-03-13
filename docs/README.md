[![Build Status](https://travis-ci.org/aws/csi-driver-amazon-efs.svg?branch=master)](https://travis-ci.org/aws/csi-driver-amazon-efs)
[![Coverage Status](https://coveralls.io/repos/github/aws/csi-driver-amazon-efs/badge.svg?branch=master)](https://coveralls.io/github/aws/csi-driver-amazon-efs?branch=master)

**WARNING**: This driver is currently an ALPHA release. This means that there may potentially be backwards compatible breaking changes moving forward. Do NOT use this driver in a production environment in its current state.

**DISCLAIMER**: This is not an officially supported Amazon product

## Amazon EFS CSI Driver

The [Amazon Elastic File System](https://aws.amazon.com/efs/) Container Storage Interface (CSI) Driver implements [CSI](https://github.com/container-storage-interface/spec/blob/master/spec.md) specification for container orchestrators to manage lifecycle of Amazon EFS filesystems.

### CSI Specification Compability Matrix
| AWS EFS CSI Driver \ CSI Version       | v0.3.0| v1.0.0 |
|----------------------------------------|-------|--------|
| master branch                          | yes   | no     |

## Features
Currently only static provisioning is supported. This means a AWS EFS filesystem needs to be created manually on AWS first. After that it could be mounted inside container as a volume using the driver.

The following CSI interfaces are implemented:
* Node Service: NodePublishVolume, NodeUnpublishVolume, NodeGetCapabilities, NodeGetInfo, NodeGetId
* Identity Service: GetPluginInfo, GetPluginCapabilities, Probe

### Encryption In Transit
One of the advantages of using EFS is that it provides [encryption in transit](https://aws.amazon.com/blogs/aws/new-encryption-of-data-in-transit-for-amazon-efs/) support using TLS. Using encryption in transit, data will be encrypted during its transition over the network to EFS service. This provides extra layer of defence-in-depth for applications that requires strict secuity compliance.

To enable encryption in transit, `tls` needs to be set at `NodePublishVolumeRequest.VolumeCapability.MountVolume` object's `MountFlags` fields. For example of using it in kuberentes, see persistence volume manifest in [Encryption in Transit Example](../examples/kubernetes/encryption_in_transit/specs/pv.yaml)

**Note** Kubernetes version 1.13+ is required if you are using this feature in Kuberentes.

## EFS CSI Driver on Kubernetes
The following sections are Kubernetes specific. If you are Kubernetes user, use this for driver features, installation steps and examples.

### Kubernetes Version Compability Matrix
| AWS EFS CSI Driver \ Kubernetes Version| v1.11 | v1.12 | v1.13 |
|----------------------------------------|-------|-------|-------|
| master branch                          | yes   | yes   | yes   |

### Container Images
|EFS CSI Driver Version     | Image                               |
|---------------------------|-------------------------------------|
|master branch              |amazon/aws-efs-csi-driver:latest     |

### Features
* Static provisioning - EFS filesystem needs to be created manually first, then it could be mounted inside container as a persistence volume (PV) using the driver.
* Mount Options - Mount options could be specified in persistence volume (PV) to define how the volume should be mounted. Aside from normal mount options, you can also specify `tls` as mount option to enable encryption in transit of EFS filesystem.

**Notes**:
* Since EFS is an elastic filesystem that doesn't really enforce any filesystem capacity. The actual storage capacity value in persistence volume and persistence volume claim is not used when creating the filesystem. However, since the storage capacity is a required field by Kubernetes, you must specify the value and you can use any valid value for the capacity.

### Installation
Checkout the project:
```sh
>> git clone https://github.com/aws/aws-efs-csi-driver.git
>> cd aws-efs-csi-driver
```

Deploy the driver:

```sh
>> kubectl apply -f deploy/kubernetes/controller.yaml
>> kubectl apply -f deploy/kubernetes/node.yaml
```

### Examples
Before the example, you need to:
* Get yourself familiar with how to setup Kubernetes on AWS and how to [create EFS filesystem](https://docs.aws.amazon.com/efs/latest/ug/getting-started.html).
* When creating EFS filesystem, make sure it is accessible from Kuberenetes cluster. This can be achieved by creating the filesystem inside the same VPC as Kubernetes cluster or using VPC peering.
* Install EFS CSI driver following the [Installation](README.md#Installation) steps.

#### Example links
* [Static provisioning](../examples/kubernetes/static_provisioning/README.md)
* [Encryption in transit](../examples/kubernetes/encryption_in_transit/README.md)
* [Accessing the filesystem from multiple pods](../examples/kubernetes/multiple_pods/README.md)

## Development
Please go through [CSI Spec](https://github.com/container-storage-interface/spec/blob/master/spec.md) and [General CSI driver development guideline](https://kubernetes-csi.github.io/docs/Development.html) to get some basic understanding of CSI driver before you start.

### Requirements
* Golang 1.11.4+

### Dependency
Dependencies are managed through go module. To build the project, first turn on go mod using `export GO111MODULE=on`, to build the project run: `make`

### Testing
To execute all unit tests, run: `make test`

## License
This library is licensed under the Apache 2.0 License. 
