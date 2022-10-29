//
//  GroupView.swift
//  My University
//
//  Created by Yura Voevodin on 28.10.2022.
//  Copyright © 2022 Yura Voevodin. All rights reserved.
//

import SwiftUI

struct GroupView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                List {
                    Section {
                        VStack(alignment: .leading) {
                            Text("Управління науковими проектами")
                                .font(.body)
                            Text("Лекція")
                                .font(.footnote)
                                .fontWeight(.light)
                        }
                    } header: {
                        Text("1 ПАРА (08:00-09:20)")
                    }
                    
                    Section {
                        VStack(alignment: .leading) {
                            Text("Управління науковими проектами")
                                .font(.body)
                            Text("Лекція")
                                .font(.footnote)
                                .fontWeight(.light)
                        }
                    } header: {
                        Text("2 ПАРА (09:40-11:00)")
                    }
                    
                    Section {
                        VStack(alignment: .leading) {
                            Text("Управління науковими проектами")
                                .font(.body)
                            Text("Лекція")
                                .font(.footnote)
                                .fontWeight(.light)
                        }
                    } header: {
                        Text("3 ПАРА (11:20-12:40)")
                    }
                    
                    Section {
                        VStack(alignment: .leading) {
                            Text("Управління науковими проектами")
                                .font(.body)
                            Text("Лекція")
                                .font(.footnote)
                                .fontWeight(.light)
                        }
                    } header: {
                        Text("5 ПАРА (14:00-15:20)")
                    }
                    
                    Section {
                        VStack(alignment: .leading) {
                            Text("Тест")
                                .font(.body)
                        }
                    } header: {
                        Text("6 ПАРА")
                    }
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                
                ToolbarItem(placement: .status) {
                    Button {
                        
                    } label: {
                        Text("вівторок, 1 листопада")
                    }
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("ІН-81/1")
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView()
    }
}
