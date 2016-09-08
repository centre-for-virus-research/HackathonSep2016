package uk.ac.gla.cvr.hackathon2016;

import java.util.function.Function;

import uk.ac.gla.cvr.hackathon2016.data.MergeTable;

public enum SequenceMetric {
	gc(MergeTable.GC_PROPERTY, "GC content"),
	gcs(MergeTable.GCS_PROPERTY, "GC-skew"),
	cpg(MergeTable.CPG_PROPERTY, "CpG island content"),
	cwf(MergeTable.CWF_PROPERTY, "Woottoon and Federhen value"),
	ce(MergeTable.CE_PROPERTY, "Shannon Entropy"),
	cz(MergeTable.CZ_PROPERTY, "Compression factor using Gzip"),
	refLength(MergeTable.REF_LENGTH_PROPERTY, "Contig length", d -> ((Integer)d).doubleValue()),
	mappedReads(MergeTable.MAPPED_READS_PROPERTY, "Mapped reads", d -> ((Integer)d).doubleValue());

	private String description;
	private String mergeTableProperty;
	private Function<Object, Double> propValToDouble;
	
	private SequenceMetric(
			String mergeTableProperty, String description, 
			Function<Object, Double> propValToDouble) {
		this.mergeTableProperty = mergeTableProperty;
		this.description = description;
		this.propValToDouble = propValToDouble;
	}

	private SequenceMetric(String mergeTableProperty, String description) {
		this(mergeTableProperty, description, obj -> ((Float) obj).doubleValue());
	}

	public String getDescription() {
		return description;
	}

	public String getMergeTableProperty() {
		return mergeTableProperty;
	}

	public Double mapToDouble(Object propertyVal) {
		return propValToDouble.apply(propertyVal);
	}
	
	
	
	
}