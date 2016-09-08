select `ContigID`, `Seq` from MergeTable
WHERE `blast_subjectId` is NULL AND `diamond_subjectId` is NULL 
