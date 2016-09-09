package uk.ac.gla.cvr.hackathon2016;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.json.JsonArray;
import javax.json.JsonArrayBuilder;
import javax.json.JsonNumber;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.json.JsonString;
import javax.json.JsonValue;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;

import org.apache.cayenne.ObjectContext;
import org.apache.cayenne.exp.Expression;
import org.apache.cayenne.exp.ExpressionFactory;
import org.apache.cayenne.query.SelectQuery;

import uk.ac.gla.cvr.hackathon2016.data.Analysis;
import uk.ac.gla.cvr.hackathon2016.data.KnownDark;
import uk.ac.gla.cvr.hackathon2016.data.MergeTable;
import uk.ac.gla.cvr.hackathon2016.data.Sample;
import uk.ac.gla.cvr.hackathon2016.data.Sequence;
import uk.ac.gla.cvr.hackathon2016.document.JsonUtils;

public class Hackathon2016Controller {

	public static Logger logger = Logger.getLogger("uk.ac.gla.cvr.hackathon2016");
	
	public Hackathon2016Controller() {
	}

	@GET()
	@Path("/sequenceMetrics")
	@Produces(MediaType.APPLICATION_JSON)
	public String getSequenceMetrics(@Context HttpServletResponse response) {
		JsonArrayBuilder jsonArrayBuilder = JsonUtils.jsonArrayBuilder();
		for(SequenceMetric sequenceMetric: SequenceMetric.values()) {
			jsonArrayBuilder.add(JsonUtils.jsonObjectBuilder()
					.add("property", sequenceMetric.getMergeTableProperty())
					.add("description", sequenceMetric.getDescription()));
		}
		JsonObject resultObject = JsonUtils.jsonObjectBuilder()
				.add("sequenceMetrics", jsonArrayBuilder.build())
				.build();
		return JsonUtils.prettyPrint(resultObject);
	}
	
	@SuppressWarnings("unchecked")
	@GET()
	@Path("/samples")
	@Produces(MediaType.APPLICATION_JSON)
	public String getSamples(@Context HttpServletResponse response) {
		try {
			System.out.println("GET samples");
			ObjectContext objectContext = Hackathon2016Database.getInstance().getServerRuntime().getContext();
			SelectQuery query = new SelectQuery(Sample.class);
			List<Sample> samples = (List<Sample>) objectContext.performQuery(query);

			JsonArrayBuilder arrayBuilder = JsonUtils.jsonArrayBuilder();
			for(Sample sample: samples) {
				JsonObjectBuilder sampleObjBuilder = JsonUtils.jsonObjectBuilder();
				
				sampleObjBuilder.add("ID", sample.getSmpID());
				sampleObjBuilder.add("Source", sample.getSource());
				Optional.ofNullable(sample.getMetagenomics())
				.ifPresent(s -> sampleObjBuilder.add("Is metagenomics?", s == 1 ? "Yes" : "No"));
				Optional.ofNullable(sample.getHost())
				.ifPresent(s -> sampleObjBuilder.add("Host", s));
				Optional.ofNullable(sample.getOwner())
				.ifPresent(s -> sampleObjBuilder.add("Owner", s));
				Optional.ofNullable(sample.getCollectionDate())
				.ifPresent(s -> sampleObjBuilder.add("Collection date", DateFormat.getDateInstance().format(s)));
				arrayBuilder.add(sampleObjBuilder.build());
			}
			JsonObject result = JsonUtils.jsonObjectBuilder()
					.add("samples", arrayBuilder.build())
					.build();

			String commandResult = JsonUtils.prettyPrint(result);
			System.out.println("commandResult: "+commandResult);
			addCacheDisablingHeaders(response);
			return commandResult;
		} catch(Throwable th) {
			logger.log(Level.SEVERE, "Error during GET samples: "+th.getMessage(), th);
			throw th;
		} 
	} 

	@SuppressWarnings("unchecked")
	@POST()
	@Path("/sequences")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public String getSequences(String commandString, @Context HttpServletResponse response) {
		try {
			System.out.println("POST update for :"+commandString);

			JsonObject requestObj = JsonUtils.stringToJsonObject(commandString);

			Integer sampleId = ((JsonNumber) requestObj.get("sampleId")).intValue();

			ObjectContext objectContext = Hackathon2016Database.getInstance().getServerRuntime().getContext();
			Expression exp = ExpressionFactory
					.matchExp(Sequence.SMP_ID_PROPERTY, sampleId);
			SelectQuery query = new SelectQuery(Sequence.class, exp);

			List<Sequence> sequences = (List<Sequence>) objectContext.performQuery(query);

			JsonArrayBuilder arrayBuilder = JsonUtils.jsonArrayBuilder();
			for(Sequence sequence: sequences) {
				JsonObjectBuilder sequenceObjBuilder = JsonUtils.jsonObjectBuilder();
				
				sequenceObjBuilder.add("ID", sequence.getSeqID());
				Optional.ofNullable(sequence.getLibPrep())
				.ifPresent(s -> sequenceObjBuilder.add("Library prep.", s));
				Optional.ofNullable(sequence.getTechnology())
				.ifPresent(s -> sequenceObjBuilder.add("Sequencing technology", s));
				Optional.ofNullable(sequence.getSeqType())
				.ifPresent(s -> sequenceObjBuilder.add("Paired-/single-end", s == 2 ? "Paired-end" : "Single-end"));
				
				arrayBuilder.add(sequenceObjBuilder
						.build());
			}
			JsonObject result = JsonUtils.jsonObjectBuilder()
					.add("sequences", arrayBuilder.build())
					.build();

			String commandResult = JsonUtils.prettyPrint(result);
			System.out.println("commandResult: "+commandResult);
			addCacheDisablingHeaders(response);
			return commandResult;
		} catch(Throwable th) {
			logger.log(Level.SEVERE, "Error during post: "+th.getMessage(), th);
			throw th;
		} 
	} 

	
	
	
	@SuppressWarnings("unchecked")
	@POST()
	@Path("/getContigs")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public String getContigs(String commandString, @Context HttpServletResponse response) {
		try {
			System.out.println("Get contigs for :"+commandString);

			JsonObject requestObj = JsonUtils.stringToJsonObject(commandString);
			
			String sequenceId = ((JsonString) requestObj.get("sequenceId")).getString();
			
			ObjectContext objectContext = Hackathon2016Database.getInstance().getServerRuntime().getContext();
			Expression exp = ExpressionFactory
					.matchExp(MergeTable.SEQ_ID_PROPERTY, sequenceId);
			SelectQuery query = new SelectQuery(MergeTable.class, exp);

			List<MergeTable> mergeTableRecords = (List<MergeTable>) objectContext.performQuery(query);

			JsonArrayBuilder arrayBuilder = JsonUtils.jsonArrayBuilder();
			
			List<ContigPoint> contigPoints = new ArrayList<ContigPoint>();
			Double[] maxUnscaledMetric = new Double[SequenceMetric.values().length];
			
			for(MergeTable mergeTableRecord: mergeTableRecords) {
				ContigPoint contigPoint = new ContigPoint();
				contigPoint.contigId = mergeTableRecord.getContigID();
				contigPoint.isDark = determineIfDark(mergeTableRecord);
				for(SequenceMetric metric: SequenceMetric.values()) {
					Object propertyValObj = mergeTableRecord.readProperty(metric.getMergeTableProperty());
					Double propertyVal = metric.mapToDouble(propertyValObj);
					int metricOrdinal = metric.ordinal();
					if(maxUnscaledMetric[metricOrdinal] == null || 
							propertyVal > maxUnscaledMetric[metricOrdinal]) {
						maxUnscaledMetric[metricOrdinal] = propertyVal;
					}
					contigPoint.metrics[metricOrdinal] = propertyVal;
					
				}
				contigPoints.add(contigPoint);
			}
			for(ContigPoint contigPoint: contigPoints) {
				JsonObjectBuilder contigObjBuilder = JsonUtils.jsonObjectBuilder();
				contigObjBuilder.add("contigId", contigPoint.contigId);
				contigObjBuilder.add("isDark", contigPoint.isDark);
				for(SequenceMetric sequenceMetric: SequenceMetric.values()) {
					int ordinal = sequenceMetric.ordinal();
					contigObjBuilder.add(sequenceMetric.name(), 
							contigPoint.metrics[ordinal] / maxUnscaledMetric[ordinal]);
				}
				arrayBuilder.add(contigObjBuilder.build());
			}
			JsonObject result = JsonUtils.jsonObjectBuilder()
					.add("contigs", arrayBuilder.build())
					.build();

			String commandResult = JsonUtils.prettyPrint(result);
			System.out.println("commandResult: "+commandResult);
			addCacheDisablingHeaders(response);
			return commandResult;
		} catch(Throwable th) {
			logger.log(Level.SEVERE, "Error during post: "+th.getMessage(), th);
			throw th;
		} 
	}


	
	
	@SuppressWarnings("unchecked")
	@POST()
	@Path("/getContigDetails")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public String getContigDetails(String commandString, @Context HttpServletResponse response) {
		try {
			System.out.println("Get contig details for :"+commandString);

			JsonObject requestObj = JsonUtils.stringToJsonObject(commandString);
			
			String contigId = ((JsonString) requestObj.get("contigId")).getString();
			String xMetricString = ((JsonString) requestObj.get("xMetric")).getString();
			SequenceMetric xMetric = SequenceMetric.valueOf(xMetricString);
			String yMetricString = ((JsonString) requestObj.get("yMetric")).getString();
			SequenceMetric yMetric = SequenceMetric.valueOf(yMetricString);
			
			ObjectContext objectContext = 
					Hackathon2016Database.getInstance().getServerRuntime().getContext();
			MergeTable resultContig = lookupContig(contigId, objectContext);

			JsonObjectBuilder contigObjBuilder = JsonUtils.jsonObjectBuilder();
			boolean isDark = determineIfDark(resultContig);
			contigObjBuilder.add("title", isDark ? "Dark contig" : "Known contig");
			contigObjBuilder.add("contigId", resultContig.getContigID());
			
			contigObjBuilder.add("properties", createPropertiesJsonArray(resultContig, xMetric, yMetric, isDark, objectContext));
			
			JsonObject result = contigObjBuilder.build();

			String commandResult = JsonUtils.prettyPrint(result);
			System.out.println("commandResult: "+commandResult);
			addCacheDisablingHeaders(response);
			return commandResult;
		} catch(Throwable th) {
			logger.log(Level.SEVERE, "Error during post: "+th.getMessage(), th);
			throw th;
		} 
	}
	
	private Sample lookupSample(Integer sampleId, ObjectContext objectContext) {
		Expression exp = ExpressionFactory
				.matchExp(Sample.SMP_ID_PROPERTY, sampleId);
		SelectQuery query = new SelectQuery(Sample.class, exp);
		@SuppressWarnings("unchecked")
		List<Sample> samples = (List<Sample>) objectContext.performQuery(query);
		return samples.get(0);
	}

	private KnownDark lookupKnownDark(String queryId, ObjectContext objectContext) {
		Expression exp = ExpressionFactory
				.matchExp(KnownDark.QUERY_ID_PROPERTY, queryId);
		SelectQuery query = new SelectQuery(KnownDark.class, exp);
		@SuppressWarnings("unchecked")
		List<KnownDark> knownDarks = (List<KnownDark>) objectContext.performQuery(query);
		return knownDarks.get(0);
	}

	
	private Sequence lookupSequence(String sequenceId, ObjectContext objectContext) {
		Expression exp = ExpressionFactory
				.matchExp(Sequence.SEQ_ID_PROPERTY, sequenceId);
		SelectQuery query = new SelectQuery(Sequence.class, exp);
		@SuppressWarnings("unchecked")
		List<Sequence> sequences = (List<Sequence>) objectContext.performQuery(query);
		return sequences.get(0);
	}

	private Analysis lookupAnalysis(String sequenceId, ObjectContext objectContext) {
		Expression exp = ExpressionFactory
				.matchExp(Analysis.SEQ_ID_PROPERTY, sequenceId);
		SelectQuery query = new SelectQuery(Analysis.class, exp);
		@SuppressWarnings("unchecked")
		List<Analysis> analyses = (List<Analysis>) objectContext.performQuery(query);
		return analyses.get(0);
	}

	
	
	private MergeTable lookupContig(String contigId, ObjectContext objectContext) {
		Expression exp = ExpressionFactory
				.matchExp(MergeTable.CONTIG_ID_PROPERTY, contigId);
		SelectQuery query = new SelectQuery(MergeTable.class, exp);
		@SuppressWarnings("unchecked")
		List<MergeTable> mergeTableRecords = (List<MergeTable>) objectContext.performQuery(query);
		MergeTable resultContig = mergeTableRecords.get(0);
		return resultContig;
	}

	
	
	@SuppressWarnings("unchecked")
	@POST()
	@Path("/getKnownDarkDetails")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public String getKnownDarkDetails(String commandString, @Context HttpServletResponse response) {
		try {
			System.out.println("Get known dark details for :"+commandString);

			JsonObject requestObj = JsonUtils.stringToJsonObject(commandString);
			
			String knownDarkQueryId = ((JsonString) requestObj.get("knownDarkQueryId")).getString();
			
			ObjectContext objectContext = 
					Hackathon2016Database.getInstance().getServerRuntime().getContext();
			KnownDark knownDark = lookupKnownDark(knownDarkQueryId, objectContext);

			MergeTable referenceContig = lookupContig(knownDark.getContigID(), objectContext);
			MergeTable queryContig = lookupContig(knownDark.getQueryID(), objectContext);
			
			JsonObjectBuilder resultObjBuilder = JsonUtils.jsonObjectBuilder();
			
			resultObjBuilder.add("alignmentLength", knownDark.getAlnLength());
			resultObjBuilder.add("mismatchCount", knownDark.getMismatchCount());
			resultObjBuilder.add("percentIdentity", SequenceMetric.floatToRoundedDouble(knownDark.getPercIdentity()));
			
			resultObjBuilder.add("reference", knownDarkContig(referenceContig, objectContext));
			resultObjBuilder.add("query", knownDarkContig(queryContig, objectContext));
			
			JsonObject result = resultObjBuilder.build();

			String commandResult = JsonUtils.prettyPrint(result);
			System.out.println("commandResult: "+commandResult);
			addCacheDisablingHeaders(response);
			return commandResult;
		} catch(Throwable th) {
			logger.log(Level.SEVERE, "Error during post: "+th.getMessage(), th);
			throw th;
		} 
	}

	
	
	
	private JsonObject knownDarkContig(MergeTable contig, ObjectContext objectContext) {
		Sequence sequence = lookupSequence(contig.getSeqID(), objectContext);
		Sample sample = lookupSample(sequence.getSmpID(), objectContext);
		
		JsonObjectBuilder propertiesObjBuilder = JsonUtils.jsonObjectBuilder();
		propertiesObjBuilder.add("contigId", contig.getContigID());
		propertiesObjBuilder.add("sequence", contig.getSeq());
		propertiesObjBuilder.add("sequenceId", sequence.getSeqID());
		propertiesObjBuilder.add("sampleSource", sample.getSource());
		return propertiesObjBuilder.build();
	}

	private JsonObject propertyDoubleObj(String description, Double value) {
		JsonObjectBuilder propertiesObjBuilder = JsonUtils.jsonObjectBuilder();
		propertiesObjBuilder.add("description", description);
		propertiesObjBuilder.add("value", value);
		return propertiesObjBuilder.build();
	}

	private JsonObject propertyLinkObj(String description, String value, String linkType, String... linkValues) {
		JsonObjectBuilder propertiesObjBuilder = JsonUtils.jsonObjectBuilder();
		propertiesObjBuilder.add("description", description);
		propertiesObjBuilder.add("value", value);
		propertiesObjBuilder.add("linkType", linkType);
		JsonArrayBuilder valuesArrayBuilder = JsonUtils.jsonArrayBuilder();
		for(String linkValue: linkValues) {
			valuesArrayBuilder.add(linkValue);
		}
		propertiesObjBuilder.add("linkValue", valuesArrayBuilder.build());
		return propertiesObjBuilder.build();
	}

	private JsonObject propertyStringObj(String description, String value) {
		JsonObjectBuilder propertiesObjBuilder = JsonUtils.jsonObjectBuilder();
		propertiesObjBuilder.add("description", description);
		propertiesObjBuilder.add("value", value);
		return propertiesObjBuilder.build();
	}

	private JsonArray createPropertiesJsonArray(MergeTable resultContig,
			SequenceMetric xMetric, SequenceMetric yMetric, boolean isDark, ObjectContext objectContext) {
		JsonArrayBuilder propertiesArrayBuilder = JsonUtils.jsonArrayBuilder();
		
		for(SequenceMetric metric: new LinkedHashSet<SequenceMetric>(Arrays.asList(xMetric, yMetric, SequenceMetric.mappedReads, SequenceMetric.refLength))) {
			Object propertyValObj = resultContig.readProperty(metric.getMergeTableProperty());
			propertiesArrayBuilder.add(
					propertyDoubleObj(metric.getDescription(), metric.mapToDouble(propertyValObj)));
		}
		if(isDark) {
			Set<KnownDark> relatedDarkContigs = new LinkedHashSet<KnownDark>();

			{
				Expression exp = ExpressionFactory
						.matchExp(KnownDark.QUERY_ID_PROPERTY, resultContig.getContigID());
				SelectQuery query = new SelectQuery(KnownDark.class, exp);
				@SuppressWarnings("unchecked")
				List<KnownDark> knownDarkRecords = (List<KnownDark>) objectContext.performQuery(query);
				knownDarkRecords.forEach(kdr -> relatedDarkContigs.add(kdr));
			}

			{
				Expression exp = ExpressionFactory
						.matchExp(KnownDark.CONTIG_ID_PROPERTY, resultContig.getContigID());
				SelectQuery query = new SelectQuery(KnownDark.class, exp);
				@SuppressWarnings("unchecked")
				List<KnownDark> knownDarkRecords = (List<KnownDark>) objectContext.performQuery(query);
				knownDarkRecords.forEach(kdr -> relatedDarkContigs.add(kdr));
			}
			
			relatedDarkContigs.forEach(rdc -> {
				String otherContigId;
				if(rdc.getQueryID().equals(resultContig.getContigID())) {
					otherContigId = rdc.getContigID();
				} else {
					otherContigId = rdc.getQueryID();
				}
				propertiesArrayBuilder.add(
						propertyLinkObj("Related dark contig", otherContigId, "relatedDark", rdc.getQueryID(), otherContigId));
			});

		}
		Optional.ofNullable(resultContig.getAdaptorSubjectId())
		.ifPresent(s -> {
			String accession = idToAccession(s);
			propertiesArrayBuilder.add(propertyLinkObj("Adapter sequence match", accession, "href", "http://www.ncbi.nlm.nih.gov/nuccore/"+accession));
		});
		Optional.ofNullable(resultContig.getBlastSubjectId())
		.ifPresent(s -> {
			String accession = idToAccession(s);
			propertiesArrayBuilder.add(propertyLinkObj("Nucleotide sequence match", accession, "href", "http://www.ncbi.nlm.nih.gov/nuccore/"+accession));
		});
		Optional.ofNullable(resultContig.getDiamondSubjectId())
		.ifPresent(s -> {
			String accession = idToAccession(s);
			propertiesArrayBuilder.add(propertyLinkObj("Protein sequence match", accession, "href", "http://www.ncbi.nlm.nih.gov/protein/"+accession));
		});
		propertiesArrayBuilder.add(propertyStringObj("Sequence", resultContig.getSeq()));
		return propertiesArrayBuilder.build();
	}

	private String idToAccession(String s) {
		return s.split("\\|")[3];
	}
	
	
	
	
	
	
	private class ContigPoint {
		String contigId;
		double[] metrics = new double[SequenceMetric.values().length];
		boolean isDark;
	}
	
	private boolean determineIfDark(MergeTable mergeTableRecord) {
		boolean isDark = true;
		if(mergeTableRecord.getAdaptorSubjectId() != null) {
			isDark = false;
		} else if(mergeTableRecord.getBlastSubjectId() != null) {
			isDark = false;
		} else if(mergeTableRecord.getDiamondSubjectId() != null) {
			isDark = false;
		}
		return isDark;
	} 

	
	
	// URL navigation
	@Path("/{urlPathSegment}")
	public Object handle(@PathParam("urlPathSegment") String urlPathSegment) {
		return null;
	}

	
	
	private void addCacheDisablingHeaders(HttpServletResponse response) {
		response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
		response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
		response.setHeader("Expires", "0"); // Proxies.
	}
	
}
