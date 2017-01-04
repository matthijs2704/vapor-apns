//
//  CurlUpdater.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 01/01/2017.
//
//

import Foundation
import Console

internal class CurlUpdater {
    let console: ConsoleProtocol = Terminal(arguments: CommandLine.arguments)

    private var shouldSudo = true
    
    internal func updateCurl() {
        #if os(macOS)
        updateCurlMacOS()
        #elseif os(Linux)
            let username = NSUserName()
            shouldSudo = username != "root"
        updateCurlLinux()
        #endif
    }
    
    private func updateCurlMacOS() {
        if checkBrewInstalled() {
            console.info("Installing curl using Homebrew", newLine: true)
            updateHomebrew()
            installHBCurl()
            linkHBCurl()
            done()
        }else {
            console.error("It doesn't look like you have Homebrew installed!", newLine: true)
            let response = console.ask("Would you like to install Homebrew? [y/n]")
            if response == "y" {
                installHomebrew()
            }else {
                exit(1)
            }
        }
    }
    
    private func updateCurlLinux() {
        if checkAptGetInstalled() {
            updateApt()
            installCurlBuildDep()
            installNghttpBuildDep()
            buildnghttp2()
            buildCurlLinux()
            cleanupInstallLinux()
            done()
        }else {
            console.error("It doesn't look like you have apt-get installed!", newLine: true)
            exit(1)
        }
    }
 
    private func done() {
        console.success("🚀 Done! Now ", newLine: true)
    }
    
    // MARK: - apt-get (Linux/Ubuntu)
    private func checkAptGetInstalled() -> Bool {
        let (_, result) = shell("which", arguments: ["apt-get"])
        return result == 0
    }

    private func updateApt() {
        let uaLoadingBar = console.loadingBar(title: "Updating apt-get...")
        uaLoadingBar.start()
        let (_, uaUpdateResult) = shell("\(shouldSudo ? "sudo" : "")", arguments: ["apt-get", "-qq", "update"])
        if uaUpdateResult == 0 {
            uaLoadingBar.finish()
        }else {
            uaLoadingBar.fail()
            exit(1)
        }
    }
    
    private func installCurlBuildDep() {
        let cbdLoadingBar = console.loadingBar(title: "Installing curl build dependencies...")
        cbdLoadingBar.start()
        let (_, cbdUpdateResult) = shell("\(shouldSudo ? "sudo" : "")", arguments: ["apt-get", "-y", "-qq", "build-dep", "curl"])
        if cbdUpdateResult == 0 {
            cbdLoadingBar.finish()
        }else {
            cbdLoadingBar.fail()
            exit(1)
        }
    }
    
    private func installNghttpBuildDep() {
        let nghbdLoadingBar = console.loadingBar(title: "Installing nghttp2 build dependencies...")
        nghbdLoadingBar.start()
        let (_, nghbdUpdateResult) = shell("\(shouldSudo ? "sudo" : "")", arguments: ["apt-get", "-y", "-qq", "install", "git", "g++", "make", "binutils", "autoconf", "automake", "autotools-dev", "libtool", "pkg-config", "zlib1g-dev", "libcunit1-dev", "libssl-dev", "libxml2-dev", "libev-dev", "libevent-dev", "libjansson-dev", "libjemalloc-dev", "cython", "python3-dev", "python-setuptools"])
        if nghbdUpdateResult == 0 {
            nghbdLoadingBar.finish()
        }else {
            nghbdLoadingBar.fail()
            exit(1)
        }
    }
    
    private func buildnghttp2() {
        let cwd = FileManager.default.currentDirectoryPath
//        print("script run from:\n" + cwd)
//        let (currentWorkDirr, _) = shell("pwd", workPath: "\(cwd)/nghttp2")
//        fatalError("\(currentWorkDirr)/nghttp2")
        let cloneLoadingBar = console.loadingBar(title: "Cloning nghttp2...")
        cloneLoadingBar.start()
        let (gitCloneOutput, gitCloneResult) = shell("git", arguments: ["clone", "--quiet", "https://github.com/tatsuhiro-t/nghttp2.git"])
        if gitCloneResult != 0 {
            cloneLoadingBar.fail()
            console.error(gitCloneOutput, newLine: true)
            exit(1)
        }
        cloneLoadingBar.finish()
        
        let buildingLoadingBar = console.loadingBar(title: "Building nghttp2...")
        buildingLoadingBar.start()
//        let currentWorkDir = cwd
//        let (autoreconfOutput, autoreconfResult) = shell("/usr/bin/autoreconf", arguments: ["-i", "\(currentWorkDir)/nghttp2"])
//        if autoreconfResult != 0 {
//            buildingLoadingBar.fail()
//            console.error(autoreconfOutput, newLine: true)
//            exit(1)
//        }
//        
//        let (automakeOutput, automakeResult) = shell("/usr/bin/automake", workPath: "\(currentWorkDir)/nghttp2")
//        if automakeResult != 0 {
//            buildingLoadingBar.fail()
//            console.error(automakeOutput, newLine: true)
//            exit(1)
//        }
//        
//        let (autoconfOutput, autoconfResult) = shell("/usr/bin/autoconf", workPath: "\(currentWorkDir)/nghttp2")
//        if autoconfResult != 0 {
//            buildingLoadingBar.fail()
//            console.error(autoconfOutput, newLine: true)
//            exit(1)
//        }
//        
//        let (configureOutput, configureResult) = shell("./configure", workPath: "\(currentWorkDir)/nghttp2")
//        if configureResult != 0 {
//            buildingLoadingBar.fail()
//            console.error(configureOutput, newLine: true)
//            exit(1)
//        }
//        
//        let (makeOutput, makeResult) = shell("make", workPath: "\(currentWorkDir)/nghttp2")
//        if makeResult != 0 {
//            buildingLoadingBar.fail()
//            console.error(makeOutput, newLine: true)
//            exit(1)
//        }

        // Workaround for swift bug not using task.currentDirectoryPath
        let buildScriptText = "#! /usr/bin/env bash\ncd nghttp2\nautoreconf -i > /dev/null 2>&1\nautomake > /dev/null 2>&1\nautoconf > /dev/null 2>&1\n./configure\nmake > /dev/null 2>&1"
        let installScriptText = "#! /usr/bin/env bash\ncd nghttp2\n\(shouldSudo ? "sudo" : "") make install > /dev/null 2>&1"
        let currentDirectory = URL(fileURLWithPath: FileManager().currentDirectoryPath)
        let destination = currentDirectory
        
        do {
            try buildScriptText.write(to: destination.appendingPathComponent("build_nghttp2.sh"), atomically: false, encoding: String.Encoding.utf8)
            try installScriptText.write(to: destination.appendingPathComponent("install_nghttp2.sh"), atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            buildingLoadingBar.fail()
            console.wait(seconds: 1.0)
            console.error("\(error)")
            console.wait(seconds: 1.0)
            exit(1)
        }
        
        let (buildOutput, buildResult) = shell("sh", arguments: ["build_nghttp2.sh", "&>/dev/null"])
        if buildResult != 0 {
            buildingLoadingBar.fail()
            console.error(buildOutput, newLine: true)
            exit(1)
        }
        buildingLoadingBar.finish()

        let installLoadingBar = console.loadingBar(title: "Installing nghttp2...")
        installLoadingBar.start()
        let (_, installResult) = shell("sh", arguments: ["install_nghttp2.sh", "&>/dev/null"])
        if installResult == 0 {
            installLoadingBar.finish()
        }else {
            installLoadingBar.fail()
            exit(1)
        }
        
//        let (_, installResult) = shell("\(shouldSudo ? "sudo" : "")", arguments: ["make", "install"])
//        if installResult == 0 {
//            installLoadingBar.finish()
//        }else {
//            installLoadingBar.fail()
//            exit(1)
//        }
    }
    
    func buildCurlLinux() {
        let downloadLoadingBar = console.loadingBar(title: "Downloading curl...")
        downloadLoadingBar.start()
        let (wgetOutput, wgetResult) = shell("wget", arguments: ["-q", "http://curl.haxx.se/download/curl-7.52.1.tar.bz2"])
        if wgetResult != 0 {
            downloadLoadingBar.fail()
            console.error(wgetOutput, newLine: true)
            exit(1)
        }
        downloadLoadingBar.finish()
        
        let unpackLoadingBar = console.loadingBar(title: "Unpacking curl...")
        unpackLoadingBar.start()
        let (untarOutput, untarResult) = shell("tar", arguments: ["-xjf", "curl-7.52.1.tar.bz2"])
        if untarResult != 0 {
            unpackLoadingBar.fail()
            console.error(untarOutput, newLine: true)
            exit(1)
        }
        unpackLoadingBar.finish()
        
        let currentDirectory = URL(fileURLWithPath: FileManager().currentDirectoryPath)
        let destination = currentDirectory
        
        let buildingLoadingBar = console.loadingBar(title: "Building curl...")
        buildingLoadingBar.start()
        let buildScriptText = "#! /usr/bin/env bash\ncd curl-7.52.1\n./configure --with-nghttp2=/usr/local --with-ssl > /dev/null 2>&1\nmake > /dev/null 2>&1"
        let installScriptText = "#! /usr/bin/env bash\ncd curl-7.52.1\n\(shouldSudo ? "sudo" : "") make install > /dev/null 2>&1\n\(shouldSudo ? "sudo" : "") ldconfig > /dev/null 2>&1"
        do {
            try buildScriptText.write(to: destination.appendingPathComponent("build_curl.sh"), atomically: false, encoding: String.Encoding.utf8)
            try installScriptText.write(to: destination.appendingPathComponent("install_curl.sh"), atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            buildingLoadingBar.fail()
            console.wait(seconds: 1.0)
            console.error("\(error)")
            console.wait(seconds: 1.0)
            exit(1)
        }
        
        let (buildOutput, buildResult) = shell("sh", arguments: ["build_curl.sh", ">/dev/null"])
        if buildResult != 0 {
            buildingLoadingBar.fail()
            console.error(buildOutput, newLine: true)
            exit(1)
        }
        buildingLoadingBar.finish()
        
        let installLoadingBar = console.loadingBar(title: "Installing curl...")
        installLoadingBar.start()
        let (_, installResult) = shell("sh", arguments: ["install_curl.sh", ">/dev/null"])
        if installResult == 0 {
            installLoadingBar.finish()
        }else {
            installLoadingBar.fail()
            exit(1)
        }

    }
    
    func cleanupInstallLinux() {
        let currentDirectory = URL(fileURLWithPath: FileManager().currentDirectoryPath)
        let destination = currentDirectory
        
        let cleanupLoadingBar = console.loadingBar(title: "Cloning nghttp2...")
        cleanupLoadingBar.start()
        try? FileManager.default.removeItem(at: destination.appendingPathComponent("build_nghttp2.sh"))
        try? FileManager.default.removeItem(at: destination.appendingPathComponent("install_nghttp2.sh"))
        try? FileManager.default.removeItem(at: destination.appendingPathComponent("nghttp2/"))
        
        try? FileManager.default.removeItem(at: destination.appendingPathComponent("build_curl.sh"))
        try? FileManager.default.removeItem(at: destination.appendingPathComponent("install_curl.sh"))
        try? FileManager.default.removeItem(at: destination.appendingPathComponent("curl-7.52.1.tar.bz2"))
        try? FileManager.default.removeItem(at: destination.appendingPathComponent("curl-7.52.1", isDirectory: true))
        cleanupLoadingBar.finish()
    }
    
    // MARK: - Homebrew (macOS)
    private func checkBrewInstalled() -> Bool {
        let (_, result) = shell("which", arguments: ["-s", "brew"])
        return result == 0
    }
    
    private func updateHomebrew() {
        let ubLoadingBar = console.loadingBar(title: "Updating Homebrew...")
        ubLoadingBar.start()
        let (_, breUpdateResult) = shell("brew", arguments: ["update"])
        if breUpdateResult == 0 {
            ubLoadingBar.finish()
        }else {
            ubLoadingBar.fail()
            exit(1)
        }
    }
    
    // MARK: Curl installation
    private func installHBCurl() {
        let icLoadingBar = console.loadingBar(title: "Installing curl...")
        icLoadingBar.start()
        let (_, installCurlResult) = shell("brew", arguments: ["reinstall", "curl", "--with-openssl", "--with-nghttp2"])
        if installCurlResult == 0 {
            icLoadingBar.finish()
        }else {
            icLoadingBar.fail()
            exit(1)
        }
    }
    
    private func linkHBCurl() {
        let lcLoadingBar = console.loadingBar(title: "Linking curl...")
        lcLoadingBar.start()
        let (_, linkCurlResult) = shell("brew", arguments: ["link", "curl", "--force"])
        if linkCurlResult == 0 {
            lcLoadingBar.finish()
        }else {
            lcLoadingBar.fail()
            exit(1)
        }
    }
    
    // MARK: Homebrew installation
    private func installHomebrew() {
        let installHBLoadingBar = console.loadingBar(title: "Installing Homebrew...")
        installHBLoadingBar.start()
        let (hbInstallOutput, installHBResult) = shell("/usr/bin/ruby", arguments: ["-e", "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"])
        if installHBResult == 0 {
            installHBLoadingBar.finish()
        }else {
            installHBLoadingBar.fail()
            console.error("Installing Homebrew failed!\nHomebrew install output:\n\(hbInstallOutput)", newLine: true)
            exit(1)
        }
        
        runHomebrewDoctor()
    }
    
    private func runHomebrewDoctor() {
        let brewDoctorLoadingBar = console.loadingBar(title: "Running Homebrew doctor...")
        brewDoctorLoadingBar.start()
        let (brewDoctorOutput, brewDoctorResult) = shell("brew", arguments: ["doctor"])
        if brewDoctorResult == 0 {
            brewDoctorLoadingBar.finish()
        }else {
            brewDoctorLoadingBar.fail()
            console.error("brew doctor failed!\nOutput:\n\(brewDoctorOutput)", newLine: true)
            exit(1)
        }
    }

    // MARK: - Shell command execution
    @discardableResult
    func shell(_ command: String, arguments: [String] = [], workPath: String = "") -> (String, Int32)
    {
        var args = arguments
        if (command != "") {
        args.insert(command, at: 0)
        }
        
//        if workPath != "" {
//            args = ["bash", "-c", "\"cd \(workPath) && \(args.joined(separator: " "))\""]
//        }
//        print (args.joined(separator: " "))
        #if os(macOS)
            let task = Process()
        #elseif os(Linux)
            let task = Task()
        #endif
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        
//        task.currentDirectoryPath = workPath
        
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)!
        if output.characters.count > 0 {
            //remove newline character.
            let lastIndex = output.index(before: output.endIndex)
            return (output[output.startIndex ..< lastIndex], task.terminationStatus)
        }
        return (output, task.terminationStatus)
    }
}
