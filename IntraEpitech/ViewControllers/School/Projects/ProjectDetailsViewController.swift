//
//  ProjectDetailsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 25/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ProjectDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var masterProfileImage: UIImageView!
    @IBOutlet weak var masterNameLabel: UILabel!
    @IBOutlet weak var projectEndLabel: UILabel!
    @IBOutlet weak var projectEndProgressView: UIProgressView!
    @IBOutlet weak var projectTableView: UITableView!
    
    // Project data
    var project: Project!
    
    // Project members
    var members = [User]()
    
    // Project files
    var files = [File]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.title = self.project.actiTitle
        
        if let end = self.project.end {
            self.projectEndLabel.text = end.toDate().toProjectEnding()
        }
        
        if let files = self.project.files {
            self.files = files
        }
        
        self.setMasterStudentData()
        self.setProgressView()
        
        self.projectTableView.estimatedRowHeight = 60
        self.projectTableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setMasterStudentData() {
        
        if (self.project?.isRegistered() == true) {
            let grp = self.project?.findGroup((project?.userProjectCode!)!)
            self.members = (grp?.members)!
            self.masterNameLabel.text = grp?.master?.title
            setUIIfRegistered(grp)
        } else {
            self.masterNameLabel.text = NSLocalizedString("NotRegisteredProject", comment: "")
            if let img = ApplicationManager.sharedInstance.downloadedImages![(ApplicationManager.sharedInstance.user?.imageUrl)!] {
                self.masterProfileImage.image = img
                self.masterProfileImage.cropToSquare()
            }
        }
        self.masterProfileImage.cropToSquare()
        self.masterProfileImage.toCircle()
    }
    
    func setProgressView() {
        
        if let begin = self.project?.begin?.shortToDate(), let end = self.project?.end?.shortToDate() {
            
            let today = Date()
            
            let totalTime = end.timeIntervalSince(begin)
            let currentTime = end.timeIntervalSince(today)
            
            let percent = 1 - (currentTime * 100 / totalTime) / 100
            
            if end < today {
                self.projectEndProgressView.setProgress(1.0, animated: true)
                self.projectEndProgressView.progressTintColor = UIUtils.planningRedColor
            } else {
                self.projectEndProgressView.setProgress(Float(percent), animated: true)
                if (percent > 0.8) {
                    self.projectEndProgressView.progressTintColor = UIUtils.planningOrangeColor
                } else {
                    self.projectEndProgressView.progressTintColor = UIUtils.planningGreenColor
                }
            }
        }
    }

    func setUIIfRegistered(_ grp: ProjectGroup?) {
        
        if let profileImageURL = grp?.master?.imageUrl {
            self.masterProfileImage.downloadProfileImage(fromURL: URL(string: profileImageURL)!)
        }
//        
//        
//        if let img = ApplicationManager.sharedInstance.downloadedImages![(grp?.master?.imageUrl)!] {
//            self.masterProfileImage.image = img
//            self.masterProfileImage.cropToSquare()
//        } else {
//            ImageDownloader.downloadFrom(link: (grp?.master?.imageUrl)!) {_ in
//                if let img = ApplicationManager.sharedInstance.downloadedImages![(grp?.master?.imageUrl)!] {
//                    self.masterProfileImage.image = img
//                    self.masterProfileImage.cropToSquare()
//                    self.masterProfileImage.toCircle()
//                }
//            }
//        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.files.count : self.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return indexPath.section == 0 ? self.getFileCell(for: self.files[indexPath.row]) : self.getStudentCell(for: self.members[indexPath.row])
    }
    
    func getFileCell(for file: File) -> UITableViewCell {
        
        let cell = self.projectTableView.dequeueReusableCell(withIdentifier: "fileCell")!
        let titleLabel = cell.viewWithTag(1) as! UILabel
        
        titleLabel.text = file.title!
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func getStudentCell(for member: User) -> UITableViewCell {
        
        let cell = self.projectTableView.dequeueReusableCell(withIdentifier: "userCell")!
        let imgView = cell.viewWithTag(1) as! UIImageView
        let userLabel = cell.viewWithTag(2) as! UILabel
        let statusImgView = cell.viewWithTag(3) as!UIImageView
        
        imgView.image = UIImage(named: "userProfile")
        
        userLabel.text = member.title
        
        if (member.status == "confirmed") {
            statusImgView.image = UIImage(named: "Done")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImgView.tintColor = UIUtils.planningGreenColor
        } else {
            statusImgView.image = UIImage(named: "Delete")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImgView.tintColor = UIUtils.planningRedColor
        }
        
        if let profileImageURL = member.imageUrl, let url = URL(string: profileImageURL) {
            imgView.downloadProfileImage(fromURL: url)
        }
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let file = self.files[indexPath.row]
            open(file: file)
        }
    }
    
    func open(file: File) {
        
        let vc = WebViewController()
        
        vc.file = file
        
        self.show(vc, sender: self)

    }
}
