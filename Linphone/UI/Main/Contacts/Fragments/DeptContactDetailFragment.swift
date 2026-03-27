//
//  DeptContactDetailFragment.swift
//  LinphoneApp
//
//  Created by hvn-dyan on 27/3/26.
//


import SwiftUI



struct DeptContactDetailFragment: View {
    let user: DeptUserItem
    @ObservedObject var departmentViewModel: DepartmentViewModel
    @ObservedObject private var contactsManager = ContactsManager.shared
    var onDismiss: (() -> Void)?
    @Environment(\.openURL) private var openURL
    
    private var contactAvatarModel: ContactAvatarModel {
        ContactAvatarModel(
            friend: nil,
            name: user.userNm,
            address: "",
            withPresence: false
        )
    }
    
    private var isUserAlreadyInContacts: Bool {
        let trimmedName = user.userNm.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedMobile = (user.mobile ?? "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "")
        let normalizedOffice = (user.officeTel ?? "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "")
        
        return contactsManager.avatarListModel.contains { avatar in
            let sameName = avatar.name.trimmingCharacters(in: .whitespacesAndNewlines) == trimmedName
            let avatarPhones = avatar.phoneNumbersWithLabel.map {
                $0.phoneNumber.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "")
            }
            let samePhone = (!normalizedMobile.isEmpty && avatarPhones.contains(normalizedMobile))
                || (!normalizedOffice.isEmpty && avatarPhones.contains(normalizedOffice))
            return sameName || samePhone
        }
    }
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                        infoSection
                        Spacer(minLength: 24)
                    }
                }
                .background(Color(.systemGroupedBackground))

                if !isUserAlreadyInContacts {
                    actionButton
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGroupedBackground))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onDismiss?()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.primary)
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            
            VStack(spacing: 8) {
                Avatar(contactAvatarModel: contactAvatarModel, avatarSize: 100, hidePresence: true)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                Text(user.userNm)
                    .font(.title2).bold()
                  
                if let dept = user.deptNm, !dept.isEmpty {
                    Text(dept)
                        .font(.subheadline)
                        
                }
                if let grade = user.gradeNm,
                    !grade.trimmingCharacters(in: .whitespaces).isEmpty
                {
                    Text(grade)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                  
                }
            }
            .padding(.bottom, 20)
        }
    }

    private var infoSection: some View {
        VStack(spacing: 0) {
            if let compNm = user.compNm, !compNm.isEmpty {
                infoRow(icon: "building.2", label: compNm)
            }
            if let duty = user.duty, !duty.isEmpty {
                infoRow(icon: "person.fill", label: duty)
            }
            if let deptNm = user.deptNm, !deptNm.isEmpty {
                infoRow(icon: "square.grid.2x2", label: deptNm)
            }
            if let email = user.email, !email.isEmpty {
                infoRow(
                    icon: "envelope",
                    label: email,
                    action: {
                        openURL(URL(string: "mailto:\(email)")!)
                    }
                )
            }
            // Mobile - highlighted
            if let mobile = user.mobile, !mobile.isEmpty {
                phoneRow(icon: "iphone", label: mobile, isMobile: true)
            }
            // Office Tel - highlighted
            if let tel = user.officeTel, !tel.isEmpty {
                phoneRow(icon: "phone", label: tel, isMobile: false)
            }
            if let fax = user.officeFax, !fax.isEmpty {
                infoRow(icon: "printer", label: fax)
            }
            if let addr = user.officeAddr,
                !addr.trimmingCharacters(in: .whitespaces).isEmpty
            {
                infoRow(icon: "mappin.and.ellipse", label: addr)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
  
    private var actionButton: some View {
        Button {
            departmentViewModel.addUserToContacts(user) {
                onDismiss?()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 16, weight: .semibold))
                Text("연락처 저장")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.orangeMain500)
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

 
    @ViewBuilder
    private func infoRow(
        icon: String,
        label: String,
        action: (() -> Void)? = nil
    ) -> some View {
        Button {
            action?()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 22)
                    .foregroundStyle(Color.gray)
                Text(label)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .disabled(action == nil)
        Divider().padding(.leading, 50)
    }
    @ViewBuilder
    private func phoneRow(icon: String, label: String, isMobile: Bool)
        -> some View
    {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .frame(width: 22)
                .foregroundStyle(Color.gray)
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.primary)
            Spacer()
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        Divider().padding(.leading, 50)
    }
}
#Preview {
    DeptContactDetailFragment(
        user: DeptUserItem(
            userId: "1",
            userNm: "권은엽",
            compCd: "60",
            compNm: "(주)인티큐브",
            deptCd: "60_601833",
            deptNm: "AVAYA구축팀",
            gradeCd: "L3",
            gradeNm: "팀장",
            email: "eykwon@inticube.com",
            officeTel: "02-6005-3864",
            officeFax: "02-6005-4343",
            officeAddr: "서울특별시 마포구 월드컵북로 396",
            mobile: "010-2280-0291",
            duty: "PBX",
            userSt: "Y",
            inputDt: nil,
            updateDt: nil
        ),
        departmentViewModel: DepartmentViewModel()
    )
}
