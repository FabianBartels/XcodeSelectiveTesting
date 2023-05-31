//
//  Created by Mike Gerasymenko <mike@gera.cx>
//

import Foundation
import PathKit
import Changeset
import Workspace
import Logger
import DependencyCalculator
import TestConfigurator

public final class SelectiveTestingTool {
    private let baseBranch: String
    private let projectWorkspacePath: Path
    private let renderDependencyGraph: Bool
    private let scheme: String

    public init(baseBranch: String, projectWorkspacePath: String, scheme: String, renderDependencyGraph: Bool) {
        self.baseBranch = baseBranch
        self.projectWorkspacePath = Path(projectWorkspacePath)
        self.renderDependencyGraph = renderDependencyGraph
        self.scheme = scheme
    }

    public func run() async throws -> Set<TargetIdentity> {
        Logger.message("Running...")
        
        // 1. Identify changed files
        let changeset = try Changeset.gitChangeset(at: projectWorkspacePath.parent(), baseBranch: baseBranch)
        Logger.message("Changed files: \(changeset)")
        
        // 2. Parse workspace: find which files belong to which targets and target dependencies
        let workspaceInfo = try WorkspaceInfo.parseWorkspace(at: projectWorkspacePath)
        
        if renderDependencyGraph {
            Logger.message(try await workspaceInfo.dependencyStructure.renderToASCII())
            
            workspaceInfo.files.keys.forEach { key in
                print("\(key.simpleDescription): ")
                workspaceInfo.files[key]?.forEach { filePath in
                    print("\t\(filePath)")
                }
            }
        }
        
        // 3. Find affected targets
        let affectedTargets = workspaceInfo.affectedTargets(changedFiles: changeset)
        
        // 4. Configure workspace to test given targets
        try enableTests(at: projectWorkspacePath,
                        scheme: scheme,
                        targetsToTest: affectedTargets)
        
        return affectedTargets
    }
}
