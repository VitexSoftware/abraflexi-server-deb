#!groovy
pipeline {
    agent none
    stages {
        stage('debian-stable') {
            agent {
                docker { image 'debian:stable' }
            }
            steps {
                sh 'cat /etc/apt/sources.list'
                sh 'apt update && apt upgrade'
                sh 'apt -y instal debuild git wget curl'
                dir('build/debian/package') {
                    sh 'git clone --depth 1 --single-branch $GIT_URL'
                    sh '(cd dashel && which debuild && debuild -i -us -uc -b)'
                    sh 'mv *.deb *.changes *.build $WORKSPACE/dist/debian/'
                }
                stash includes: 'dist/**', name: 'dist-debian'
            }
        }

        stage('debian-testing') {
            agent {
                docker { image 'debian:testing' }
            }
            steps {
                sh 'cat /etc/apt/sources.list'
                sh 'apt update && apt upgrade'
                sh 'apt -y instal debuild git wget curl'
                dir('build/debian/package') {
                    sh 'git clone --depth 1 --single-branch $GIT_URL'
                    sh '(cd dashel && which debuild && debuild -i -us -uc -b)'
                    sh 'mv *.deb *.changes *.build $WORKSPACE/dist/debian/'
                }
            }
        }
        stage('ubuntu-stable') {
            agent {
                docker { image 'ubuntu' }
            }
            steps {
                sh 'cat /etc/apt/sources.list'
                sh 'apt update && apt upgrade'
                sh 'apt -y instal debuild git wget curl'
                dir('build/debian/package') {
                    sh 'git clone --depth 1 --single-branch $GIT_URL'
                    sh '(cd dashel && which debuild && debuild -i -us -uc -b)'
                    sh 'mv *.deb *.changes *.build $WORKSPACE/dist/debian/'
                }
            }
        }
        stage('ubuntu-hirsute') {
            agent {
                docker { image 'ubuntu:hirsute' }
            }
            steps {
                sh 'cat /etc/apt/sources.list'
                sh 'apt update && apt upgrade'
                sh 'apt -y instal debuild git wget curl'
                dir('build/debian/package') {
                    sh 'git clone --depth 1 --single-branch $GIT_URL'
                    sh '(cd dashel && which debuild && debuild -i -us -uc -b)'
                    sh 'mv *.deb *.changes *.build $WORKSPACE/dist/debian/'
                }
            }
           }
    }
}